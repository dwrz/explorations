var parseJSON = function(json) {
  const REGEX = {
    false: /false/,
    null: /null/,
    number: /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/,
    true: /true/,
    value: /[a-z]|[0-9]|-/
  };
  let currentIndex = -1;
  const LAST_INDEX = json.length - 1;
  let currentChar = () => json[currentIndex];
  let parseTree = {};

  parse();
  return assemble(parseTree);

  function parse(parent) {
    if (parent && parent.type === 'key') { parent = getAncestorObject(parent); }

    if (currentIndex < LAST_INDEX) {
      currentIndex++;
      if (currentChar() === undefined) { throw new SyntaxError(); }
      if (shouldSkip(currentChar())) { currentIndex++; }

      // OBJECTS
      if (currentChar() === '{') {
        if (currentIndex === 0) { // Root.
          parseTree.root = new Node('object', null, false, null);
        } else if (parent.type === 'object') {
          if (isExpectedValue(parent)) { // Object value of a key.
            let parentKey = parent.children[parent.children.length - 1];
            let node = new Node('object', parentKey, false, null);
            parentKey.children.push(node);
            parse(node);
          }
        } else if (parent.type === 'array') { // Object value in an array.
          let node = new Node('object', parent, false, null);
          parent.children.push(node);
          parse(node);
        } // Else, throw error?
      }

      // KEYS, STRINGS
      if (currentChar() === '"') {
        if (parent.type === 'object') {
          if (isExpectedValue(parent)) { // String value of a key.
            currentIndex++; // Skip over the " and into the content.
            let value = captureTo('"');
            let parentKey = parent.children[parent.children.length - 1];
            let node = new Node('value', parentKey, true, value);
            parentKey.children.push(node);
          } else { // Key.
            currentIndex++; // Skip over the " and into the content.
            let value = captureTo('"');
            let node = new Node('key', parent, true, value);
            parent.children.push(node);
          }
        } else if (parent.type === 'array') { // String value in an array.
          currentIndex++; // Skip over the " and into the content.
          let value = captureTo('"');
          let node = new Node('value', parent, true, value);
          parent.children.push(node);
        }
      }

      // ARRAYS
      if (currentChar() === '[') {
        if (currentIndex === 0) {
          parseTree.root = new Node('array', null, false, null);
          parseTree.root.validated = parse(parseTree.root);
        } else if (parent.type === 'object') {
          if (isExpectedValue(parent)) { // Object value of a key.
            let parentKey = parent.children[parent.children.length - 1];
            let node = new Node('array', parentKey, false, null);
            parentKey.children.push(node);
            parse(node);
          }
        } else if (parent.type === 'array') { // Array value in an array.
          let node = new Node('array', parent, false, null);
          parent.children.push(node);
          parse(node);
        }
      }

      // BOOLEANS, NULL, NUMBERS
      if (currentChar().match(REGEX.value)) { // Boolean, null, or number.
        let nearestDelimiter = findNearestDelimiter();
        let value = getValue(captureTo(nearestDelimiter));
        if (parent.type === 'object') {
          let node = new Node ('value', parent.children[parent.children.length - 1], true, value);
          parent.children[parent.children.length - 1].children.push(node);
        } else if (parent.type === 'array') {
          let node = new Node ('value', parent, true, value);
          parent.children.push(node);
        }
      }

      // VALIDATORS
      // Must be last for program to work.
      if (currentChar() === '}') {
        if (parent) {
          if (parent.type === 'object') { parent.validated = true; }
          else { // Parent is a key.
            let ancestor = getAncestorObject(parent);
            ancestor.validated = true;
          }
        } else {
          parseTree.root.validated = true; // If there isn't a parent, validate the root.
        }
      }

      if (currentChar() === ']') {
        if (parent) {
          if (parent.type === 'array') { parent.validated = true; }
          else { // Parent is a key.
            let ancestor = getAncestorObject(parent);
            ancestor.validated = true;
          }
        } else {
          parseTree.root.validated = true; // If there isn't a parent, validate the root.
        }
      }
    } else { // Parse complete.

      if (parent) {
        if (parent.validated === false) { throw new SyntaxError(); }
        else if (parent.validated === true && parent.type === 'key') {
          let ancestor = getAncestorObject(parent);
          if (ancestor.validated === false) { throw new SyntaxError(); }
        }
      } else if (parseTree.root.validated === false) { throw new SyntaxError(); }
      else { return true; }
    }

    if (parent) {
      if (parent.validated === false) {
        parse(parent);
      } else if (parent.validated === true && parent.type === 'object' || parent.type === 'array') {
        parse(parent.parent);
      } else if (parent.validated === true && parent.type === 'key') {
        let ancestor = getAncestorObject(parent);
        parse(ancestor.parent);
      }
    } else if (parseTree.root.validated === false) { parse(parseTree.root); }
    else if (parseTree.root.validated === true) { return true; }
    else { throw new SyntaxError(); }
  }

  function shouldSkip(char){
    if (char === ':') { return true; }
    if (char === ',') { return true; }
    if (char === ' ') { return true; }
    else { return false; }
  }

  function Node(type, parent, validated, value) {
    this.children = [];
    this.parent = parent;
    this.type = type; // object, array, key, value
    this.validated = validated;
    this.value = value;
  }

  function findNearestDelimiter() {
    let delimiters = [',', '}', ']'];
    let startIndex = currentIndex;
    let nearest = Infinity;

    let nearestDelimiter = delimiters.reduce(function testDelimiters(nearestDelimiter, delimiter) {
      let index = startIndex;
      while (index <= LAST_INDEX && index < nearest) {
        if (json[index] === delimiter) {
          nearest = index;
          return delimiter;
        }
        index++;
      } // TODO: If nothing is found, throw an error.
      return nearestDelimiter;
    }, false);

    return nearestDelimiter;
  }

  function captureTo(delimiter) {
    let value = '';

    while (json[currentIndex] !== delimiter) {
      if (json[currentIndex] === undefined) { throw new SyntaxError(); }
      if (json[currentIndex] === '\\' && json[currentIndex + 1] === '"') {
        value += json.slice(currentIndex, currentIndex + 2);
        currentIndex += 2;
      } else {
        value += json[currentIndex];
        currentIndex++;
      }
    }

    if (value.includes('\\')) { value = processEscapes(value); }
    
    return value;
  }

  function processEscapes(string) {
    let index = 0;
    let result = '';

    while (index < string.length - 1) {
      if (string[index] === '\\') {
        if (string[index + 1] === '\\') {
          result += '\\';
          index++;
        } else if (string[index + 1] === '"') {
          result += '"';
          index++;
        } 
      } else {
        result += string[index];
      }
      index++;
    }
    return result;
  }
  
  function isExpectedValue(parent) {
    let lastChild = parent.children[parent.children.length - 1];
    if (lastChild && lastChild.type === 'key' && lastChild.children.length === 0) { return true; }
    else { return false; }
  }

  function getValue(string) {
    if (string.match(REGEX.true)) { return true; }
    else if (string.match(REGEX.false)) { return false; }
    else if (string.match(REGEX.null)) { return null; }
    else if (string.match(REGEX.number)) { return Number(string.match(REGEX.number)[0]); }
    else { throw new SyntaxError(); } // TODO: If no match, throw error.
  }

  function getAncestorObject(parent) {
    let ancestor = parent.parent;

    while (ancestor.type !== 'object') {
      ancestor = getAncestorObject(ancestor);
    }

    return ancestor;
  }

  function assemble(tree) {
    let result;

    if (tree.root.validated) {
      if (tree.root.type === 'object') { result = {}; }
      else if (tree.root.type === 'array') { result = []; }
      else { throw new Error('Not a JSON object.'); }
    } else { throw new Error ('Parse error.'); }

    processNodes(tree.root.children, result);
    return result;

    function processNodes(nodes, parent) {
      nodes.forEach(function convertNode(node){

        if (node.parent.type === 'object') {
          if (node.type === 'key') {
            if (node.children[0].type === 'value') {
              parent[node.value] = node.children[0].value;
            } else if (node.children[0].type === 'object') {
              parent[node.value] = {};
              if (node.children[0].children.length > 0) {
                processNodes(node.children[0].children, parent[node.value]);
              }
            } else if (node.children[0].type === 'array') {
              parent[node.value] = [];
              if (node.children[0].children.length > 0) {
                processNodes(node.children[0].children, parent[node.value]);
              }
            }
          }
        }

        if (node.parent.type === 'array') {
          if (node.type === 'value') {
            parent.push(node.value);
          } else if (node.type === 'object') {
            let object = {};
            parent.push(object);
            processNodes(node.children, object);
          } else if (node.type === 'array') {
            let array = [];
            parent.push(array);
            processNodes(node.children, array);
          }
        }
      });
    }
  }
};
