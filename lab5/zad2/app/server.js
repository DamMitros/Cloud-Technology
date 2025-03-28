// A simple but deep joke in code form:

function tellJoke() {
  const joke = {
    setup: "Why do programmers prefer dark mode?",
    punchline: "Because light attracts bugs!"
  };

  console.log(joke.setup);
  setTimeout(() => console.log(joke.punchline), 2000); // Adds a dramatic pause
}

tellJoke();