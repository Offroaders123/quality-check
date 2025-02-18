#!/usr/bin/env node
 // @ts-check

const fs = require("fs");
const path = require("path");
const stringSimilarity = require("string-similarity");

const [folder1, folder2, _yes] = process.argv.slice(2);

const yes = typeof _yes === "string";

if (!folder1 || !folder2 || yes && _yes !== "-y") {
  console.error("Usage: ./fuzzy-rename.js <source> <destination> [-y]");
  process.exit(1);
}

if (!yes) {
  console.log("dry run (pass '-y' to rename)");
}

// Get file names without extensions
const getSongName = ( /** @type {string} */ filename) => path.parse(filename).name;

const files1 = fs.readdirSync(folder1).map((file) => getSongName(file));
const files2 = fs.readdirSync(folder2);
const files2Names = files2.map((file) => getSongName(file));

for (const file1 of files1) {
  if (files2Names.includes(file1)) {
    console.log(`Skipping: ${file1} (already correctly named)`);
    continue;
  }

  const matches = stringSimilarity.findBestMatch(file1, files2Names);
  const bestMatchIndex = matches.bestMatchIndex;
  // console.log(file1, matches, bestMatchIndex);

  if (matches.bestMatch.rating > 0.2) { // Adjust threshold as needed
    const oldFilePath = path.join(folder2, files2[bestMatchIndex]);
    const ext = path.extname(files2[bestMatchIndex]);
    const newFilePath = path.join(folder2, `${file1}${ext}`);

    if (yes) fs.renameSync(oldFilePath, newFilePath);
    console.log(`Renamed: ${files2[bestMatchIndex]} -> ${file1}${ext}`);
  } else {
    console.log(`No close match found for: ${file1}`);
  }
}
