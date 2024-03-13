<script lang="ts" context="module">
	import { fade } from 'svelte/transition';
	export interface TileProps {
		file: string;
		prediction: number;
		showPrediction: boolean;
		isCorrect: boolean;
	}
</script>

<script lang="ts">
	let { file, prediction, showPrediction, isCorrect } = $props<TileProps>();
</script>

<div class="tile">
	<img class="tile-img" src={`/images/${file}`} />
	{#if showPrediction}
		<p transition:fade={{ delay: 250, duration: 300 }}>
			{prediction}
			{#if isCorrect}
				<span class="correct">Correct</span>
			{:else}
				<span class="wrong">Wrong</span>
			{/if}
		</p>
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
	}

	.wrong {
		color: red;
	}
</style>
