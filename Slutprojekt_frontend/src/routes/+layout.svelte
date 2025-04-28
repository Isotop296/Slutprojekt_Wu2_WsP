
<script>
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { page } from '$app/stores';

	import '../app.css';
	let { children } = $props();

	let menuOpen = false;

	const token = browser ? localStorage.getItem("token") : null;
	console.log("token here:", token);

</script>


{#if $page.url.pathname !== '/' && $page.url.pathname !== '/Create_Account'}
  <nav class="flex justify-between items-center px-6 py-5 bg-[#171d25] relative" id="navbar">

	<a href="/index"><img src="/steam.png" alt="Logo" class="h-12 -mt-2 drop-shadow-lg rounded-xl"/></a>
  

    <button class="md:hidden text-white" on:click={() => (menuOpen = !menuOpen)}>
      {#if menuOpen}
        ✖
      {:else}
        ☰
      {/if}
    </button>

    <div class="hidden md:flex items-center gap-4">
		<input type="text" placeholder="Search games..." class="px-4 py-2 rounded-full bg-gray-100 text-black focus:outline-none focus:ring-2 focus:ring-blue-400 w-50 h-8"/>	  
      <!-- kanske ha en annan bild här under beroende på om man är inloggad eller inte. hittade dock ingen -->
		{#if token} 
        <a href="/profile">
          <img src="/icon2.png" alt="profile" class="h-10 w-10 rounded-full border-2 border-white shadow-md" />
        </a>
      {:else}
        <a href="/login">
          <img src="/icon2.png" alt="login" class="h-10 w-10 rounded-full border-2 border-white shadow-md" />
        </a>
      {/if}
    </div>

    {#if menuOpen}
    <div class="absolute top-full left-0 w-full bg-[#171d25] flex flex-col items-center py-4 md:hidden">
      <input type="text" placeholder="Search" class="px-3 py-2 mb-4 rounded-lg text-black w-2/3" />
      {#if token}
        <a href="/profile" class="text-white mb-2">Profile</a>
      {:else}
        <a href="/login" class="text-white mb-2">Login</a>
      {/if}
    </div>
    {/if}

  </nav>
{/if}


{@render children()}

