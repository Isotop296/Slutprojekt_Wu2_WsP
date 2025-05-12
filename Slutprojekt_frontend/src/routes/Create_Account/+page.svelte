
<div class="min-h-screen bg-cover bg-center" style="background-image: url('/Steam.jpg');">
<section class="min-h-screen flex flex-col justify-center items-center p-6">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
      <h2 class="text-2xl font-semibold text-center text-gray-800 mb-6">Create Account</h2>
  
      <section class="login_box">
        <form on:submit={create} class="grid gap-4">
    
          <div>
            <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
            <input type="text" id="username" bind:value={username} required
              class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          </div>
  
          <div>
            <label for="country" class="block text-sm font-medium text-gray-700">Country</label>
            <input type="text" id="country" bind:value={country} required
              class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          </div>
  
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
            <input type="email" id="email" bind:value={email} required
              class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          </div>
  
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
            <input type="password" id="password" bind:value={password} required
              class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          </div>
 
          <div>
            <button type="submit"
              class="w-full py-2 px-4 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
              Submit
            </button>
          </div>
  
        </form>
      </section>
  
      <code class="block text-center text-red-500 mt-4">{message}</code>
  
      <div class="flex justify-between mt-4 text-sm">
        <a href="index" class="text-blue-500 hover:text-blue-700">Login later?</a>
        <a href="/" class="text-blue-500 hover:text-blue-700">Login?</a>
      </div>
    </div>
  </section>
</div>


  <script>
    import { goto } from "$app/navigation";
    import { redirect } from "@sveltejs/kit";
    import { browser } from '$app/environment';

  
    let message = "";
    let password = "";
    let email = "";
    let username = "";
    let country = "";
  
    async function create() {
      try {
        const res = await fetch("http://localhost:9292/api/users/create_account", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ email, password, username, country }),
          credentials: "include"
        });
  
        if (res.ok) {
          const data = await res.json();
          message = "Account created successfully!";
          console.log("Success:", data);
          goto("/index");
        } else {
          message = "Invalid credentials.";
        }
      } catch (error) {
        message = "Failed to create account.";
        console.error("Error:", error);
      }
    }
  </script>
  
