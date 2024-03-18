<script lang="ts">
	import { walk } from 'svelte/compiler';
	import { tiles } from '../../src/rounds';
	import UserRound from '../components/UserRound.svelte';
	import Tile from '../components/Tile.svelte';
	import ComputerRound from '../components/ComputerRound.svelte';
	import { Confetti } from 'svelte-confetti';
	import Celebration from '../components/Celebration.svelte';

	let maxRoundNo = Math.max(...tiles.map((t) => t.round_number));
	let rounds = $state([
		Math.floor(Math.random() * maxRoundNo),
		Math.floor(Math.random() * maxRoundNo),
		Math.floor(Math.random() * maxRoundNo)
	]);

	console.log('max round No ', maxRoundNo, rounds);

	let phase = $state<'user' | 'computer' | 'result' | 'score'>('user');
	let current_round = $state(0);
	let scoreCard = $state<Array<{ userScore: number; computerScore: number }>>(
		rounds.map((r) => ({ userScore: 0, computerScore: 0 }))
	);

	let tilesForRound = $derived(tiles.filter((t) => t.round_number === rounds[current_round]));
	console.log(tilesForRound);

	function userDone(score: number) {
		console.log('user score ', score);
		scoreCard[current_round].userScore = score;
		phase = 'computer';
	}

	function computerDone(score: number) {
		scoreCard[current_round].computerScore = score;
		phase = 'result';
	}

	function doneRound() {
		if (current_round + 1 < rounds.length) {
			console.log('next round');
			phase = 'user';
			current_round += 1;
		} else {
			console.log('scores');
			phase = 'score';
		}
	}

	function reset() {
		rounds = [
			Math.floor(Math.random() * maxRoundNo),
			Math.floor(Math.random() * maxRoundNo),
			Math.floor(Math.random() * maxRoundNo)
		];
		scoreCard = rounds.map((r) => ({ userScore: 0, computerScore: 0 }));
		current_round = 0;
		phase = 'user';
	}
</script>

<div id="container">
	<h1>Are you smarter than a foundation model!</h1>
	{#if phase !== 'score'}
		<p>Put the tiles in the order of increasing air pollution</p>

		{#if phase === 'result'}
			{#if scoreCard[current_round].computerScore > scoreCard[current_round].userScore}
				<h1 class="ai-win">AI wins again pitiful human!!!!</h1>
			{:else if scoreCard[current_round].computerScore < scoreCard[current_round].userScore}
				<h1 class="human-win">You won this round!</h1>
				<Celebration />
			{:else}
				<h1 class="human-win">It's a draw (thats actually pretty good)</h1>
				<Celebration />
			{/if}
			<button on:click={doneRound}>
				{#if current_round + 1 === rounds.length}
					See Final Scores
				{:else}
					Next Round!
				{/if}
			</button>
		{:else}
			<h2>Round {current_round + 1}</h2>
		{/if}

		<UserRound
			roundNo={current_round}
			tiles={tilesForRound}
			on:done={(score) => userDone(score.detail.score)}
			roundComplete={phase === 'result'}
		/>

		{#if ['computer', 'result'].includes(phase)}
			<ComputerRound
				roundNo={current_round}
				tiles={tilesForRound}
				on:done={(score) => computerDone(score.detail.score)}
				roundComplete={phase === 'result'}
			/>
		{/if}
	{/if}

	{#if phase === 'score'}
		<div class="score_card">
			<h1>Scores</h1>
			{#each rounds as round, index}
				<h1>
					Round {index + 1}:
					{#if scoreCard[current_round].computerScore > scoreCard[current_round].userScore}
						<span class="ai-win">AI won</span>
					{:else if scoreCard[current_round].computerScore < scoreCard[current_round].userScore}
						<span class="human-win">You won</span>
						<Celebration />
					{:else}
						<span class="human-win">Draw</span>
						<Celebration />
					{/if}
				</h1>
			{/each}
			<button on:click={() => reset()}>Try again?</button>
		</div>
	{/if}
</div>

<style>
	.ai-win {
		color: red;
	}
	.human-win {
		color: green;
	}
	#container {
		width: 100vw;
		height: 100vh;
		background-image: linear-gradient(0deg, rgb(217, 175, 217) 0%, rgb(151, 217, 225) 100%);
		color: white;
		padding: 2rem;
		box-sizing: border-box;
		overflow-y: auto;
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
