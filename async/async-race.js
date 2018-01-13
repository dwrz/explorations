const async = require('async');

const delay = 10000;
const randomTimeoutLogs = [];

const randomTimeoutLog = (n, multiplier) => {
  return (cb) => {
    const logAndResolveN = () => {
      console.log(`Number ${n} was called!`);
      cb(null, n);
    };
    setTimeout(logAndResolveN, Math.random() * multiplier);
  };
};

for (let i = 0; i < 10; i++) {
  randomTimeoutLogs.push(randomTimeoutLog(i, delay));
}

async.race(
  randomTimeoutLogs,
  (err, first) => {
    console.log(`The first function to complete returned ${first}!`);
  },
);
