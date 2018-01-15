// SEE:
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*

function* generator() {
  console.log('STEP 1.');
  yield; // yields undefined
  console.log('STEP 2.');
  yield 1;
  console.log('STEP 3.');
  return 'FIN';
}

generator();
// generator { [[GeneratorStatus]]: "suspended" }

generator().next();
// "STEP 1."
// Object { value: undefined, done: false }

try {
  generator().next().next(); // "STEP 1."
} catch (err) {
  console.error(err); // TypeError: generator(...).next(...).next is not a function… {  }
}

const next = generator().next();
// "STEP 1."

console.log(next);
// Object { value: undefined, done: false }

try {
  next();
} catch (err) {
  console.error(err); // TypeError: next is not a function… {  }
}

try {
  next.next();
} catch (err) {
  console.error(err); // TypeError: next.next is not a function… {  }
}

const useGenerator = generator();
try {
  useGenerator();
} catch (err) {
  console.error(err); // TypeError: useGenerator is not a function… {  }
}

useGenerator.next();
// "STEP 1."
// Object { value: undefined, done: false }
useGenerator.next();
// "STEP 2."
// Object { value: 1, done: false }
useGenerator.next();
// "STEP 3."
// Object { value: "FIN", done: true }
