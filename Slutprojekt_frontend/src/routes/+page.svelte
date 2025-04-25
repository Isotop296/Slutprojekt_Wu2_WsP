<section class="box content-around">
    <h2 class="Titel-L">Login</h2>

    <section class="login_box">
        <form on:submit={login}>
            <label for="email">Email</label>
            <input type="email" id="email" bind:value={email} required>

            <label for="password">Password</label>
            <input type="password" id="password" bind:value={password} required>

            <input type="submit" id="submit" value="Submit">

        </form>
    </section>
    <code>{message}</code>
    <a href="index" class="redirekt">Login later?</a>
    <a href="Create_Account" class="redirekt">Create account?</a>
</section>

<script>
	import { goto } from "$app/navigation";
	import { redirect } from "@sveltejs/kit";
    import { browser } from '$app/environment';
  


    let message = "";
    let password = "";
    let email = "";

	async function login(){
    try {
        const res = await fetch("http://localhost:9292/api/login", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ email, password }),
			});

			if (res.ok) {
				const data = await res.json();
                localStorage.setItem("token", data.token);
				goto("/index"); 
			} else {
				message = "Invalid credentials.";
			}
    } catch (error) {
      message = "Failed to log in.";
      console.error("Error fetching data:", error);
    }
    
}

</script>

<style>
.box {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    background-image: url(/giphy.gif);
    background-size: cover;
}


.login_box {
    background: rgba(255, 255, 255, 0.1); 
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    width: 300px;
    text-align: center;
}

h2 {
    color: white;
    font-size: 24px;
}

label {
    display: block;
    color: white;
    margin-top: 10px;
    font-size: 14px;
    text-align: left;
}

input[type="email"],
input[type="password"] {
    width: 100%;
    padding: 10px;
    margin-top: 5px;
    border: none;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.2);
    color: white;
}

input[type="email"]:focus,
input[type="password"]:focus {
    outline: none;
    background: rgba(255, 255, 255, 0.3);
}

input[type="submit"] {
    width: 100%;
    margin-top: 15px;
    padding: 10px;
    background: #ff4b2b;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    transition: background 0.3s ease;
}

input[type="submit"]:hover {
    background: #ff6b4b;
}

.redirekt {
    display: block;
    margin-top: 15px;
    color: #ff6b4b;
    text-decoration: none;
    font-size: 14px;
}

.redirekt:hover {
    text-decoration: underline;
}


</style>