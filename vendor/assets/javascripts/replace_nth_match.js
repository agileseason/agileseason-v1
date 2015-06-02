var replaceNthMatch = function (original, pattern, n, replace) {
  var parts, tempParts;

  if (pattern.constructor === RegExp) {

    // If there's no match, bail
    if (original.search(pattern) === -1) {
      return original;
    }

    // Every other item should be a matched capture group;
    // between will be non-matching portions of the substring
    parts = original.split(pattern);

    // If there was a capture group, index 1 will be
    // an item that matches the RegExp
    if (parts[1].search(pattern) !== 0) {
      throw {name: "ArgumentError", message: "RegExp must have a capture group"};
    }
  } else if (pattern.constructor === String) {
    parts = original.split(pattern);
    // Need every other item to be the matched string
    tempParts = [];

    for (var i=0; i < parts.length; i++) {
      tempParts.push(parts[i]);

      // Insert between, but don't tack one onto the end
      if (i < parts.length - 1) {
        tempParts.push(pattern);
      }
    }
    parts = tempParts;
  }  else {
    throw {name: "ArgumentError", message: "Must provide either a RegExp or String"};
  }

  // Parens are unnecessary, but explicit. :)
  indexOfNthMatch = (n * 2) - 1;

if (parts[indexOfNthMatch] === undefined) {
  // There IS no Nth match
  return original;
}

if (typeof(replace) === "function") {
  // Call it. After this, we don't need it anymore.
  replace = replace(parts[indexOfNthMatch]);
}

// Update our parts array with the new value
parts[indexOfNthMatch] = replace;

// Put it back together and return
return parts.join('');
}
