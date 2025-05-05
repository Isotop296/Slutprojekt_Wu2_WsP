<script>
	import { onMount } from "svelte";
    import { goto } from '$app/navigation';
    import { browser } from '$app/environment';

    let userInfo = [];
    let favoriteGamesid = [];
    let wishlistGamesid = [];
    let favoriteGames = [];
    let wishlistGames = [];
    let games = [];
    let showForm = false;

    onMount(async () => {
        await getfavorite();
        await getwishlist();
        await getgames(favoriteGamesid, 'favorite');
        await getgames(wishlistGamesid, 'wishlist');
    });


    async function getfavorite() {
        try {
      const res = await fetch("http://localhost:9292/api/favorites", {
        method: "GET",
        headers: {
          "Content-Type": "application/json"
        }
      });
      if (res.ok) {
        favoriteGamesid = await res.json();
        console.log("Favorite games:", favoriteGames);
      } else {
        console.error("Failed to fetch favorites.");
      }
    } catch (error) {
      console.error("Error fetching favorites:", error);
    }

    }

    async function getwishlist() {
        try {
      const res = await fetch("http://localhost:9292/api/wishlist", {
        method: "GET",
        headers: {
          "Content-Type": "application/json"
        }
      });
      if (res.ok) {
        wishlistGamesid = await res.json();
        console.log("Wishlist games:", wishlistGames);
      } else {
        console.error("Failed to fetch wishlist.");
      }
    } catch (error) {
      console.error("Error fetching wishlist:", error);
    }

    }

    async function getgames(Gamesid, type) {
        try {
            const res = await fetch("http://localhost:9292/api/getgames", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ game_batch1: Gamesid})
            });
            if (res.ok) {
                const fetchedGames = await res.json();
                if (type === 'favorite') {
                    favoriteGames = fetchedGames; 
                } else if (type === 'wishlist') {
                    wishlistGames = fetchedGames;  
                }
                console.log(`${type} Games:`, games);
            } else {
                console.error("Failed to fetch games.");
            }
        } catch (error) {
            console.error("Error fetching games:", error);
        }

    }


    async function removeGame(gameid, type){
        try {
            console.log("Game id:", gameid)
            const res = await fetch("http://localhost:9292/api/removegame", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({gameid: gameid, type: type})
            });
            if (res.ok) {
                if (type === "favorite") {
                favoriteGames = favoriteGames.filter(game => game.id !== gameid);
            } else if (type === "wishlist") {
                wishlistGames = wishlistGames.filter(game => game.id !== gameid);
            }
                console.log("removed");
            } else {
                console.error("Failed to remove game.");
            }
        } catch (error) {
            console.error("Error removing game:", error);
        }

    }


    function logut() {
	
	}

    async function getUserInfo(){
        try {
      const res = await fetch("http://localhost:9292/api/userinfo", {
        method: "GET",
        headers: {
          "Content-Type": "application/json"
        }
      });
      if (res.ok) {
        userInfo = await res.json();
        console.log("User info:", userInfo);
        showForm = true;
      } else {
        console.error("Failed to fetch user info.");
      }
    } catch (error) {
      console.error("Error fetching user info:", error);
    }
    }


    async function update(username, description){
        try {
            const res = await fetch("http://localhost:9292/api/userinfo/update", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({username: username, description: description})
            });
            if (res.ok) {
                console.log("saved");
                showForm = false;
            } else {
                console.error("Failed to save new info.");
            }
        } catch (error) {
            console.error("Error saving information:", error);
        }


    }


</script>



<h1>Jag hann inte med mer så det fick räka med detta som profile. :)</h1>
<button on:click={logut()} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">Log ut</button>

<button on:click={getUserInfo()} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">Edit Profile</button>

{#if showForm}
<form on:submit={update(userInfo.username, userInfo.description)} class="grid gap-4">
    <label> Username:<input type="text" bind:value={userInfo.username} class="px-3 py-2 rounded-lg border border-gray-300 focus:ring focus:ring-blue-300"/>
      </label>
      <label>description:<input type="text" bind:value={userInfo.description} class="px-3 py-2 rounded-lg border border-gray-300 focus:ring focus:ring-blue-300"/>
      </label>
    
      <button type="submit" class="w-30 h-10 py-2 px-2 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 font-size: 18px;">Spara ändringar</button>
    
   </form>
{/if}

<h2>Favoritspel</h2>
{#if favoriteGames.length > 0}
  <ul>
    {#each favoriteGames as game}
      <li>{game.name}</li> 
      <button on:click={removeGame(game.id, "favorite")} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">remove</button>
    {/each}
  </ul>
{:else}
  <p>Inga favoritspel än.</p>
{/if}

<h2>Wishlist</h2>
{#if wishlistGames.length > 0}
  <ul>
    {#each wishlistGames as game}
      <li>{game.name}</li> 
      <button on:click={removeGame(game.id, "wishlist")} class="bg-green-600 text-white px-4 py-2 rounded-full hover:bg-green-700 transition">remove</button>
    {/each}
  </ul>
{:else}
  <p>Din wishlist är tom.</p>
{/if}