#!/usr/bin/env node
// @ts-check

const fs = require("fs");
const path = require("path");
const stringSimilarity = require("string-similarity");

const [folder1, folder2] = process.argv.slice(2);

if (!folder1 || !folder2) {
    console.error("Usage: ./fuzzy-rename.js <source> <destination>");
    process.exit(1);
}

// Get file names without extensions
const getSongName = (/** @type {string} */ filename) => path.parse(filename).name;

const files1 = fs.readdirSync(folder1).map((file) => getSongName(file));
const files2 = fs.readdirSync(folder2);

for (const file1 of files1) {
    const names2 = files2.map((file) => getSongName(file));
    const matches = stringSimilarity.findBestMatch(file1, names2);
    const bestMatchIndex = matches.bestMatchIndex;
    // console.log(file1, matches, bestMatchIndex);

    if (matches.bestMatch.rating > 0.2) { // Adjust threshold as needed
        const oldFilePath = path.join(folder2, files2[bestMatchIndex]);
        const ext = path.extname(files2[bestMatchIndex]);
        const newFilePath = path.join(folder2, `${file1}${ext}`);

        // fs.renameSync(oldFilePath, newFilePath);
        console.log(`Renamed: ${files2[bestMatchIndex]} -> ${file1}${ext}`);
    } else {
        console.log(`No close match found for: ${file1}`);
    }
}
