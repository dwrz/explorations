const cb = (s) => {
  console.log('CB!');
  console.log(s);
};

const f = (cb) => {
  cb('1!');
  console.log('NOT RETURNED, BUT STILL LOGGING!');
  return cb('2!');
  console.log('RETURNED, WON\'T LOG!');
};

f(cb);
