
<script>
	import { onMount  } from 'svelte';
	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import '../app.css';
	import { goto } from '$app/navigation';
  import { user, userStatus } from '../stores/userStore';



	let { children } = $props();

	let menuOpen = false;

	onMount(async () => {
		if (browser) {
      console.log('user befor:', $user, $userStatus);
      console.log('User log start:');
      await user_log();
      console.log('User log end:');
      console.log('user after:', user, userStatus);
			if ($userStatus && $page.url.pathname === '/') {
				goto('/index'); 
			}
		}
	});

  $effect(() => {
  if (browser && $page.url.pathname === '/index') {
    user_log();
  }
});
  async function user_log() {
  if (typeof window !== 'undefined') {
    try {
      const res = await fetch("http://localhost:9292/api/users", {
        method: "GET",
        credentials: "include" 
      });

      if (res.ok) {
        const userData = await res.json(); 
        console.log('Fetched user data:', userData);
        user.set(userData); 
        userStatus.set(true); 
      } else {
        console.log('Couldent fetch user data:');
        userStatus.set(false); 
      }
    } catch (error) {
      console.error('Error fetching user data:', error);
      userStatus.set(false);
    }
  }
}

</script>

{#if $page.url.pathname !== '/' && $page.url.pathname !== '/Create_Account'}

  <nav class="flex justify-between items-center px-6 py-5 bg-[#171d25] relative" id="navbar">

    <a href="/index">
      <img src="/steam.png" alt="Logo" class="h-12 drop-shadow-lg rounded-xl" />
    </a>
  
    <button class="md:hidden text-white text-2xl" on:click={() => (menuOpen = !menuOpen)}>
      {#if menuOpen}
        ✖
      {:else}
        ☰
      {/if}
    </button>
  
    <div class="hidden md:flex items-center space-x-4">
      <input
        type="text"
        placeholder="Search games..."
        class="px-4 py-2 rounded-full bg-gray-100 text-black focus:outline-none focus:ring-2 focus:ring-blue-400 w-64"
      />
  
      {#if $userStatus}
        <a href="/profile">
          <img src="/icon2.png" alt="Profile" class="h-10 w-10 rounded-full border-2 border-white shadow-md" />
        </a>
      {:else}
        <a href="/">
          <img src="/icon2.png" alt="Login" class="h-10 w-10 rounded-full border-2 border-white shadow-md" />
        </a>
      {/if}
    </div>
  
    {#if menuOpen}
      <div class="absolute top-full left-0 w-full bg-[#171d25] flex flex-col items-center py-4 md:hidden z-50">
        <input
          type="text"
          placeholder="Search games..."
          class="px-4 py-2 rounded-lg text-black w-2/3 mb-4"
        />
  
        {#if $userStatus}
          <a href="/profile" class="text-white">Profile</a>
        {:else}
          <a href="/" class="text-white">Login</a>
        {/if}
      </div>
    {/if}
  </nav>
  {/if}




{@render children()}

