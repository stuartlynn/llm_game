<script lang="ts">
	import { tiles } from '../../src/rounds';
	import Tile from '../components/Tile.svelte';
	import { dndzone } from 'svelte-dnd-action';
	import { flip } from 'svelte/animate';

	let current_round = $state(0);
	let score = $state(0);

	let round_tiles = $derived(
		tiles.map((t, index) => ({ ...t, id: index })).filter((r) => r.round_number === current_round)
	);

	let correct_order = $derived(
		round_tiles.sort((a, b) => (a.air_pollution_index > b.air_pollution_index ? 1 : -1))
	);
	$effect(() => console.log(correct_order));

	let showPrediction = $state(false);
	let round_name = $derived(round_tiles[0].round_name);
	let current_order_guess = $state(round_tiles);
	let correct_count = $derived(
		current_order_guess.filter((t, index) => t.id === correct_order.at(index).id).length
	);
	const flipDurationMs = 300;

	function handleDndConsider(e) {
		current_order_guess = e.detail.items;
	}

	function handleDndFinalize(e) {
		current_order_guess = e.detail.items;
	}
	function submit() {
		showPrediction = true;
	}
</script>

<h1>Are you smarter than a foundation model!</h1>

<h2>Put the tiles in the order of increasing air polution</h2>
<div class="round">
	<h1>Round {round_name}</h1>
	<div
		use:dndzone={{ items: current_order_guess, flipDurationMs }}
		class="tiles"
		on:consider={handleDndConsider}
		on:finalize={handleDndFinalize}
	>
		{#each current_order_guess as tile, index (tile.id)}
			<div animate:flip={{ duration: flipDurationMs }}>
				<Tile
					isCorrect={tile.id === correct_order.at(index).id}
					{showPrediction}
					file={tile.filename.replace('.tif', '.png')}
					prediction={tile.prediction}
				/>
			</div>
		{/each}
	</div>
	{#if !showPrediction}
		<button on:click={submit}>This is my guess</button>
	{:else if correct_count === current_order_guess.length}
		<p>Wow! you got them all right</p>
	{:else}
		<p>Unfortuently you only got {correct_count} out of {current_order_guess.length}</p>
	{/if}
</div>

<style>
	div.tiles {
		display: flex;
		flex-direction: row;
		column-gap: 20px;
	}
</style>
