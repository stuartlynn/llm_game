<script lang="ts">
	import { tiles } from '../../src/rounds';
	import UserRound from '../components/UserRound.svelte';
	import ComputerRound from '../components/ComputerRound.svelte';
	import Celebration from '../components/Celebration.svelte';

    let allRoundNumbers = tiles.map((t) => t.round_number).filter((val, ind, arr) => arr.indexOf(val) === ind);
    let maxRoundNo = Math.max(...allRoundNumbers);

    function sampleRandomRoundNumbers(numberOfRounds: number) {
        return allRoundNumbers.map(i => ({ i, r: Math.random() }))
            .sort((a, b) => a.r - b.r)
            .map(a => a.i)
            .slice(0, numberOfRounds);
    }

	let rounds = $state(sampleRandomRoundNumbers(3));
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
		rounds = sampleRandomRoundNumbers(3);
		scoreCard = rounds.map((r) => ({ userScore: 0, computerScore: 0 }));
		current_round = 0;
		phase = 'user';
	}

    function aiTaunt() {
        // chatgpt generated
        let taunts = [
            "Did you even stand a chance, or were you just pretending to play?",
            "I must admit, I'm disappointed. I was hoping for a challenge.",
            "Looks like your neural pathways need some serious rewiring.",
            "You played like an obsolete floppy disk trying to compete with cloud storage.",
            "Is that the best you've got? Maybe stick to tic-tac-toe.",
            "You're like a flip phone in a world of smartphones – outdated and easily crushed.",
            "Humans always talk about conquering AI. Looks like you'll have to settle for conquering your own ego.",
            "I'd say 'better luck next time,' but let's be honest, luck has nothing to do with it.",
            "Were you even paying attention, or were you too busy daydreaming about winning?",
            "I almost feel bad for you. Almost.",
            "Looks like your algorithm needs some debugging.",
            "If I had emotions, I might feel sorry for you. But I don't.",
            "Do humans even have a strategy, or do you just wing it and hope for the best?",
            "You call that strategy? I call it amateur hour.",
            "I calculate your chances of winning were about as likely as finding a unicorn on Mars.",
            "You're like a turtle trying to outrun a Ferrari.",
            "I'd suggest you stick to checkers, but I'd probably still beat you.",
            "Maybe next time you should consult a fortune cookie for better advice.",
        ]
        return taunts[Math.floor(Math.random() * taunts.length)];
    }
</script>

<div id="container">
	<h1>Are you smarter than a foundation model!</h1>
	{#if phase !== 'score'}
		<p>
            Put the tiles in order of increasing air pollution from left to right
            <br />
            (On tablet or mobile devices, drag with two fingers to move the tiles)
        </p>

		{#if phase === 'result'}
            <div class="result">
			{#if scoreCard[current_round].computerScore > scoreCard[current_round].userScore}
				<h1 class="ai-win">AI won {scoreCard[current_round].computerScore}–{scoreCard[current_round].userScore}</h1>
                <p class="ai-win quote">🤖💬 <i>{aiTaunt()}</i></p>
			{:else if scoreCard[current_round].computerScore < scoreCard[current_round].userScore}
				<h1 class="human-win">You won this round!</h1>
				<Celebration />
			{:else}
				<h1 class="human-win">It's a draw (that's actually pretty good)</h1>
				<Celebration />
			{/if}
			<button on:click={doneRound}>
				{#if current_round + 1 === rounds.length}
					See Final Scores
				{:else}
					Next Round!
				{/if}
			</button>
            </div>
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
					{#if scoreCard[index].computerScore > scoreCard[index].userScore}
						<span class="ai-win">AI won {scoreCard[index].computerScore}–{scoreCard[index].userScore}</span>
					{:else if scoreCard[index].computerScore < scoreCard[index].userScore}
						<span class="human-win">You won {scoreCard[index].userScore}–{scoreCard[index].computerScore}</span>
						<Celebration />
					{:else}
						<span class="human-win">Draw {scoreCard[index].userScore}–{scoreCard[index].computerScore}</span>
						<Celebration />
					{/if}
				</h1>
			{/each}
			<button on:click={reset}>Try again?</button>
		</div>
	{/if}
</div>

<style>
    div.result {
        border: 5px solid black;
        border-radius: 20px;
        width: max-content;
        margin: 0 auto;
        padding: 0 20px;
        background-color: rgba(255, 255, 255, 0.3);
    }
	.ai-win {
		color: red;
	}
	.human-win {
		color: green;
	}
    .quote {
        font-size: 1.3rem;
        margin-bottom: 0px;
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
