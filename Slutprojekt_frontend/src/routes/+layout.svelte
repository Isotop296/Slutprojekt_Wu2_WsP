{#if $page.url.pathname !== '/' && $page.url.pathname !== '/Create_Account'}
<div class="bg-[#203454] w-fill h-fill content-around">
<nav class="top-0 bg-[#171d25]" id="navbar">
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
</div>
{/if}

<script>
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { page } from '$app/stores';

	import '../app.css';
	let { children } = $props();

	const token = browser ? localStorage.getItem("token") : null;
	console.log("token here:", token);

</script>

{@render children()}



