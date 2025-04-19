<main>
    {#if topGames.length > 0}
      <div class="relative w-full overflow-hidden rounded-xl mb-8">
        {#each topGames as game, index (game.id)}
          <div class="{index === currentSlide ? 'block' : 'hidden'} transition duration-500 ease-in-out">
            <img src={game.background_image} alt={game.name} class="w-full h-64 object-cover rounded-xl" />
            <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4 text-white">
              <h2 class="text-xl font-bold">{game.name}</h2>
              <p class="text-sm line-clamp-2">{game.released}</p>
            </div>
          </div>
        {/each}
  
        <button on:click={prevSlide} class="absolute top-1/2 left-4 transform -translate-y-1/2 text-white text-2xl font-bold">‹</button>
        <button on:click={nextSlide} class="absolute top-1/2 right-4 transform -translate-y-1/2 text-white text-2xl font-bold">›</button>
      </div>
    {/if}
  </main>
  







<nav class="flex gap-4 mb-6 justify-center"> 
    {#each genres as genre}
    <button on:click={() => getGamesByGenre(genre)}
        class="px-4 py-2 rounded-full text-white bg-blue-600 hover:bg-blue-800 transition
        {selectedGenre === genre ? 'bg-blue-900' : ''}"
        >
        {genre} </button>
    {/each}
</nav>

<section class="grid grid-cols-2 md:grid-cols-4 gap-4">
    {#each games as game}
        <div class="">
            <h3 class="font-semibold text-lg mb-2">{game.name}</h3>
            <img src={game.background_image} alt={game.name} class="w-full h-40 object-cover rounded mb-2">
            <p class="text-sm text-gray-500">Released: {game.released}</p>
        </div>
    {/each}

    
</section>


{#if games.length > 0}
    <div class="text-center mt-6">
        <button on:click={loadMore} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">
            load more
        </button>
    </div>
{/if}


{#if message}
  <code class="block text-center text-red-500 mt-4">{message}</code>
{/if}

<script>
	import { onMount } from "svelte";
  let currentSlide = 0;
  let topGames = [];
  let genres = ["action", "adventure", "indie", "rpg", "romans"];
  let selectedGenre = "";
  let games = []; //detta felmeddelandet är okej då den bara inte vet vad arrayen ska innehålla, men koden som används vet vad den innehåller.
  let message = "";
  let page = 1;


  onMount(async () => {
    await getTopGames();
    });


  async function getGamesByGenre(genre) {
    selectedGenre = genre;
    page = 1;
    games = [];
    await loadMore(); 
  }

async function loadMore() {
    try {
        const res = await fetch("http://localhost:9292/api/GetGameByGenre", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({genre: selectedGenre, page }),
        });

        if (res.ok) {
          const data = await res.json();
          games = [...games, ...data.results];
        page += 1;
          console.log("Success:", data);
        } else {
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
      topGames = data.results;
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



</script>