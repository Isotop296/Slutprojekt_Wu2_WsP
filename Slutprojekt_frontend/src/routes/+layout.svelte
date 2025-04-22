<nav class="top-0" id="navbar">
<img src="" alt="loga">
<input type="text" placeholder="search">
{#if token}
<a href="">
<img src="" alt="profile">
</a>
{:else}
<a href="/">
<img src="" alt="login">
</a>
{/if}
</nav>

<script>
	import { onMount } from 'svelte';
	import '../app.css';
	let { children } = $props();

	const token = localStorage.getItem("token") || null;

</script>

{@render children()}



