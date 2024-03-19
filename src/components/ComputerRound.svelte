<script lang="ts">
	import type { Tile as TileType } from '../types';
	import Tile from '../components/Tile.svelte';
	import { flip } from 'svelte/animate';
	import { onMount } from 'svelte';
	import { createEventDispatcher } from 'svelte';

	interface RoundProps {
		tiles: Array<TileType>;
		roundComplete?: boolean;
	}

	const dispatch = createEventDispatcher();

	let { tiles, roundComplete } = $props<RoundProps>();
	let current_order_guess = $state<Array<TileType> | null>(null);

	let computer_guess = $derived([...tiles].sort((a, b) => (a.prediction > b.prediction ? 1 : -1)));

	let correct_order = $derived(
		[...tiles].sort((a, b) => (a.air_pollution_index > b.air_pollution_index ? 1 : -1))
	);

	let correct_count = $derived(
		computer_guess.filter((t, index) => t.id === correct_order.at(index)?.id).length
	);
    console.log('computer score ', correct_count);

    function getPredictedRank(tile: TileType) {
        return computer_guess.findIndex((t) => t.id === tile.id);
    }
    function getCorrectRank(tile: TileType) {
        return correct_order.findIndex((t) => t.id === tile.id);
    }

	onMount(() => {
		current_order_guess = [...tiles].sort((_) => Math.random() - 0.5);
		let sorter = sort();

		const intervalId = setInterval(() => {
			let { done } = sorter.next();
			if (done) {
				dispatch('done', { score: correct_count });
				clearInterval(intervalId);
			}
		}, 2000);
	});

	function* sort() {
		if (!current_order_guess) {
			throw 'tried to sort when current_order_guess is undefined';
		}
		for (let i = 0; i < current_order_guess.length - 1; i++) {
			for (let j = i; j < current_order_guess.length; j++) {
				if (current_order_guess[i].prediction > current_order_guess[j].prediction) {
					const temp = current_order_guess[j];
					current_order_guess[j] = current_order_guess[i];
					current_order_guess[i] = temp;
					yield;
				}
			}
		}
	}
</script>

<div class="round">
	<h2>AI's turn</h2>
	{#if current_order_guess}
		<div class="tiles no-exceed-width">
			{#each current_order_guess as tile, index (tile.id)}
				<div animate:flip={{ duration: 600 }}>
					<Tile
						showPrediction={true}
						showResult={roundComplete}
						file={tile.filename.replace('.tif', '.png')}
						prediction={tile.prediction}
						value={tile.air_pollution_index}
                        predictedRank={getPredictedRank(tile)}
                        actualRank={getCorrectRank(tile)}
					/>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	div.tiles {
		display: flex;
		flex-direction: row;
		column-gap: 20px;
		margin: auto;
		justify-content: center;
	}
    div.no-exceed-width {
        max-width: 100%;
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
