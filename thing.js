// @ts-check

const metadataList = require("./music-metadata.json");
const bandcampList = require("./bandcamp.json");

/**
 * @param {typeof metadataList[number]} metadata
 * @returns {string}
 */
function absoluteFlattener(metadata) {
  return metadata.path.replace("/Users/brandon/Music/Music/Media/Music/", "");
}

/** @type {string[]} */
const lowQuality = (
  metadataList
    .filter(metadata => metadata.bit_rate < 256)
    .map(absoluteFlattener)
);

/** @type {string[]} */
const highQuality = (
  metadataList
    .filter(metadata => metadata.bit_rate >= 256)
    .map(absoluteFlattener)
);

/** @type {string[]} */
const bandcampSongs = (
  metadataList
    .filter(metadata => bandcampList.includes(metadata.album))
    .map(absoluteFlattener)
);

/** @type {string[]} */
const lqNoBC = (
  lowQuality
    .filter(metadata => !bandcampSongs.includes(metadata))
);

console.log(JSON.stringify(lqNoBC, null, 2));