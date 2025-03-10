
<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>

<script>
  import { onMount } from "svelte";

  let message = "Loading...";

  onMount(async () => {
    try {
      const res = await fetch("http://localhost:9292/api/loggin");
      const data = await res.json();
      message = data.users;
    } catch (error) {
      message = "Failed to fetch data";
      console.error("Error fetching data:", error);
    }
  });
</script>

<p>Detta meddelande kommer från Sinatras backend: <code>{message}</code></p>