<script>
	import { onMount } from "svelte";
    import { browser } from '$app/environment';

  let loading = true
  let gameDescriptions = {};
  let currentSlide = 0;
  let topGames = [];
  let genres = ["action", "adventure", "indie", "rpg", "romans"];
  let selectedGenre = "";
  /**
	 * @type {string | any[]}
	 */
  let games = []; //detta felmeddelandet är okej då den bara inte vet vad arrayen ska innehålla, men koden som används vet vad den innehåller.
  let message = "";
  let page = 1;
  let selectedGame = null;
  const token = localStorage.getItem("token") || null;

  onMount(async () => {
    await getTopGames();
    loading = false
    });


  async function getGamesByGenre(genre) {
    selectedGame = null;
    selectedGenre = genre;
    page = 1;
    games = [];
    await loadMore(genre); 
  }

async function loadMore(genre) {
    try {
      console.log("genre: ", genre)
        const res = await fetch("http://localhost:9292/api/GetGameByGenre", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({genre: genre, page }),
        });

        if (res.ok) {
          const data = await res.json();
          games = [...games, ...data];
          page += 1;
          console.log("Success:", data);
        } else {
          console.log("failed:", genre)
          message = "Couldent fetch games.";
        }
      } catch (error) {
        message = "Failed to fetch games.";
        console.error("Error:", error);
      }

}


async function getTopGames() {
  try {
    const res = await fetch("http://localhost:9292/api/GetTopGames");
    if (res.ok) {
      const data = await res.json();
      topGames = data;
    } else {
      message = "Couldn't fetch top games.";
    }
  } catch (error) {
    message = "Failed to fetch top games.";
    console.error("Top Games Error:", error);
  }
}


function nextSlide() {
  currentSlide = (currentSlide + 1) % topGames.length;
}

function prevSlide() {
  currentSlide = (currentSlide - 1 + topGames.length) % topGames.length;
}



async function fetchDescription(id) {
  const res = await fetch(`http://localhost:9292/api/GetGameDetails?id=${id}`);
  const data = await res.json();
  gameDescriptions[id] = data.description;
}


function handleGameClick(game) {
  selectedGame = game;

}

async function wishlist(selectedGame){
    const res = await fetch("http://localhost:9292/api/wishlist", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
          },
          body: JSON.stringify({game_id: selectedGame.id }),
        });
}

async function favorite(selectedGame){
  const res = await fetch("http://localhost:9292/api/favorite", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
          },
          body: JSON.stringify({game_id: selectedGame.id }),
        });
      }


</script>

<div class="min-h-screen bg-cover bg-center" style="background-color: #203454;">


<main>
    {#if loading}
        <div>loading</div>

    {:else}
    {#if topGames.length > 0}
      <div class="relative w-200 h-100 overflow-hidden rounded-xl mb-8 left-55 top-10 bg-gradient-to-t from-black/80 to-black/50">
        {#each topGames as game, index (game.id)}
          <div class="{index === currentSlide ? 'block' : 'hidden'} transition duration-500 ease-in-out">
            <div class="absolute top-0 right-5 p-4 text-white w-95">
                <h2 class="text-xl font-bold">{game.name}</h2>
                <p class="text-sm line-clamp-2">{game.released}</p>
                <p class="text-sm text-gray-200 italic mt-2 leading-snug text-centre">{@html game.description}</p>
              </div>
            <img src={game.background_image} alt={game.name} class="sm:w-100 sm:h-75 w-50 h-25 object-cover rounded-xl mt-13" />
          </div>
        {/each}
  
        <button on:click={prevSlide} class="absolute top-1/2 left-4 transform -translate-y-1/2 text-white text-5xl font-bold">‹</button>
        <button on:click={nextSlide} class="absolute top-1/2 right-4 transform -translate-y-1/2 text-white text-5xl font-bold">›</button>
      </div>
    {/if}
    {/if}
  </main>
  





<section class="bg-[#171d25]">

<nav class="flex gap-4 mb-6 justify-center mt-50"> 
    {#each genres as genre}
    <button on:click={() => getGamesByGenre(genre)}
        class="px-4 py-2 rounded-full text-white bg-blue-600 hover:bg-blue-800 transition
        {selectedGenre === genre ? 'bg-blue-900' : ''}"        >
        {genre} </button>
    {/each}
</nav>

<section class="flex">
<section class="grid grid-cols-1 md:grid-cols-1 gap-4">
    {#each games as game}
        <div class="relative ml-80 bg-[#203454] w-130 h-16 rounded-xl cursor-pointer"  on:click={() => handleGameClick(game)}>
            <h3 class="absolute left-23 font-semibold text-white mt-1">{game.name}</h3>
            <img src={game.background_image} alt={game.name} class="w-20 h-16 object-cover rounded mb-2">
            <p class="absolute text-sm text-gray-400 left-23 -mt-10">Released: {game.released}</p>
        </div>
    {/each}
</section>

<section class="w-1/3 p-8 -mt-8">
  {#if selectedGame}
  <div class="bg-[#203454] p-6 rounded-xl text-white">
    <h2 class="text-2xl font-bold mb-4">{selectedGame.name}</h2>
    <img src={selectedGame.background_image} alt={selectedGame.name} class="w-full h-64 object-cover rounded mb-4" />
    <p class="text-sm mb-2">Released: {selectedGame.released}</p>
    <p class="text-base max-h-48 overflow-y-auto">{@html selectedGame.description || "Ingen beskrivning tillgänglig."}</p>
    <button class="bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition duration-300 ease-in-out" on:click={() => favorite(selectedGame)}>
  Save as favorite
</button>
    <button class="bg-green-600 text-white px-6 py-2 rounded-full hover:bg-green-700 transition duration-300 ease-in-out" on:click={() => wishlist(selectedGame)}>
  Wishlist
</button>
  </div>
  {/if}
</section>
</section>

{#if games.length > 0}
    <div class="text-center mt-6">
        <button on:click={() => loadMore(selectedGenre)} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">
            load more
        </button>
    </div>
{/if}

{#if message}
  <code class="block text-center text-red-500 mt-4">{message}</code>
{/if}
  </section>

</div>