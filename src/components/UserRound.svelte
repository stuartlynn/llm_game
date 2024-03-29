<script lang="ts">
	import type { Tile as TileType } from '../types';
	import Tile from '../components/Tile.svelte';
	import { dndzone } from 'svelte-dnd-action';
	import { flip } from 'svelte/animate';
	import { fade } from 'svelte/transition';
	import { createEventDispatcher } from 'svelte';
	import { derived } from 'svelte/store';

	interface RoundProps {
		tiles: Array<TileType>;
		roundComplete?: boolean;
	}

	const dispatch = createEventDispatcher();
	const flipDurationMs = 300;

	let { tiles, roundComplete } = $props<RoundProps>();
	let submitted = $state(false);

	let current_order_guess = $state<Array<TileType> | null>(null);

	$effect(() => {
		submitted = false;
		current_order_guess = tiles.sort((t) => Math.random() - 0.5);
	});

	let correct_order = $derived(
		[...tiles].sort((a, b) => (a.air_pollution_index >= b.air_pollution_index ? 1 : -1))
	);

	let correct_count = $derived(
		current_order_guess?.filter((t, index) => t.id === correct_order.at(index)?.id).length
	);

	$effect(() => {
		console.log('User correct order ', correct_order);
	});

	function handleDndConsider(e: any) {
		current_order_guess = e.detail.items;
	}

	function handleDndFinalize(e: any) {
		current_order_guess = e.detail.items;
	}

	function submit() {
		submitted = true;
		dispatch('done', { score: correct_count });
	}

	function getCorrectRank(tile: TileType) {
		return correct_order.findIndex((t) => t.id === tile.id);
	}

	const checks = $derived(
		current_order_guess?.reduce(
			(lookup, guess, index) => ({
				...lookup,
				[guess.id]: guess.id === correct_order.at(index)?.id
			}),
			{}
		)
	);
	const current_order_guess_withr_result = $derived(
		current_order_guess?.map((guess) => ({ ...guess, isRight: checks[guess.id] }))
	);

	$effect(() => {
		console.log('---------');
		current_order_guess?.forEach((guess, index) => {
			console.log(
				'Rank Test' +
					guess.id +
					' ' +
					correct_order.at(index)?.id +
					' ' +
					index +
					' ' +
					getCorrectRank(guess) +
					' ' +
					checks[guess.id]
			);
		});
		console.log('---------');
	});
</script>

{#if current_order_guess}
	<div class="round" in:fade={{ delay: 1000, duration: 1000 }}>
		<h2>Your Guess</h2>
		<div
			use:dndzone={{ items: current_order_guess, flipDurationMs, dragDisabled: submitted }}
			class="tiles"
			on:consider={handleDndConsider}
			on:finalize={handleDndFinalize}
		>
			{#each current_order_guess_withr_result as tile, index (tile.id)}
				<div animate:flip={{ duration: flipDurationMs }}>
					<Tile
						id={tile.id}
						isCorrect={tile.isRight}
						showResult={roundComplete}
						showPrediction={false}
						file={tile.filename.replace('.tif', '.png')}
						prediction={tile.prediction}
						value={tile.air_pollution_index}
						predictedRank={index}
						actualRank={getCorrectRank(tile)}
					/>
				</div>
			{/each}
		</div>
		{#if !submitted}
			<button on:click={submit}>This is my guess</button>
		{/if}
	</div>
{:else}
	<div>Loading...</div>
{/if}

<style>
	div.tiles {
		display: flex;
		flex-direction: row;
		column-gap: 20px;
		margin: auto;
		justify-content: center;
	}
	button {
		margin: 20px;
		background-color: #e1341e;
		color: white;
		font-weight: bold;
		border-radius: 1.2rem;
		padding: 10px 20px;
		box-sizing: border-box;
		border: none;
	}
</style>
