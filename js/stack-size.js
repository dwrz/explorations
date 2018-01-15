let stackSize = 0;

function findStackSize() {
  stackSize++;
  findStackSize();
}

try {
  findStackSize();
} catch (err) {
  console.log(stackSize);
} finally {
  process.exit();
}
