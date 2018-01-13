const currier = (f) => {
  const arity = f.length;
  const args = [];
  const curried = (...nextArgs) => {
    nextArgs.forEach(arg => args.push(arg));
    if (args.length >= arity) {
      return f(...args);
    }
    return curried;
  };
  return curried;
};
module.exports = currier;
