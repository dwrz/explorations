const delay = (time = 1000) => new Promise((resolve) => {
  setTimeout(resolve.bind(null, true), time);
});

const delay2seconds = delay.bind(null, 2000);
const delay3seconds = delay.bind(null, 3000);
const delay5seconds = delay.bind(null, 5000);

const sumDelays = (...delays) =>
  delays.reduce((promise, f) => promise
    .then(f), Promise.resolve());

const Α = () => sumDelays(delay2seconds, delay3seconds)
  .then(() => 'I AM THE Α.');

const Ω = () => delay5seconds()
  .then(() => 'I AM THE Ω.');

const executeConcurrently = (...functions) =>
  Promise.all(functions.map(f => f()));

executeConcurrently(Α, Ω)
  .then(arr => console.log(JSON.stringify(arr)))
  .then(() => {
    process.exit(0);
  })
  .catch(e => console.error(e));
