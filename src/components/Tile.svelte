<script lang="ts" context="module">
	import { fade } from 'svelte/transition';
	export interface TileProps {
		file: string;
		prediction: number;
		value: number;
		showResult: boolean;
		showPrediction: boolean;
		isCorrect: boolean;
	}
</script>

<script lang="ts">
	let { file, prediction, showPrediction, showResult, value, isCorrect } = $props<TileProps>();
</script>

<div class="tile">
	<img class="tile-img" src={`/images/${file}`} />
	{#if showResult}
		<div transition:fade={{ delay: 250, duration: 300 }} class="flex flex-column items-center">
			{#if isCorrect}
				<h2 class="correct">Correct</h2>
			{:else}
				<h2 class="wrong">Wrong</h2>
			{/if}
			{#if showPrediction}
				<p class="my-1">AI's Prediction: {prediction.toFixed(3)}</p>
				<p class="my-1">Actual Value: {value.toFixed(3)}</p>
			{/if}
		</div>
	{/if}
</div>

<style>
	.tile {
		display: flex;
		flex-direction: column;
		align-items: center;
	}
	.tile-img {
		width: 200px;
		height: 200px;
	}
	.correct {
		color: green;
		font-weight: 700;
	}

	.wrong {
		color: red;
	}
</style>
