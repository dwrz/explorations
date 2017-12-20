const a = {
  name:'alpha',
  sayName: function (yourname) {
    console.log(`Hello, ${yourname}, I'm ${this.name}.`);
  },
};

const b = {
  name:'bravo',
};

a.sayName(); // 'Hello, undefined, I'm alpha.'
b.sayName(); // TypeError, b.sayName is not a function

a.sayName('world'); //  'Hello, world, I'm alpha.'
b.sayName('world'); // TypeError, b.sayName is not a function

a.sayName.call(b, 'computer'); // 'Hello, computer, I'm bravo.'
a.sayName.call(b, 'computer').call(a, 'world'); // 'Hello, computer, I'm bravo.' + TypeError: a.sayName.call(...) is undefined

a.sayName.apply(b, 'JavaScript'); // TypeError: second argument to Function.prototype.apply must be an array
a.sayName.apply(b, ['JavaScript']); // 'Hello, JavaScript, I'm bravo.'
a.sayName.apply(b, ['JavaScript']).apply(a, 'world'); // 'Hello, JavaScript, I'm bravo.' + TypeError: a.sayName.apply(...) is undefined

a.sayName.bind(b, '.bind'); // [Function: bound]
a.sayName.bind(b, '.bind')(); // 'Hello, .bind, I'm bravo.'
a.sayName.bind(b, '.bind').bind(a, 'world'); // [Function: bound]
a.sayName.bind(b, '.bind').bind(a, 'world'); // 'Hello, .bind, I'm bravo.'

