const http = require('http');

const search = process.argv[2] || 'Huangshan';
const api = `http://maps.googleapis.com/maps/api/geocode/json?address=${search}`;

const getSearch = () => new Promise((resolve, reject) => {
  console.log('MAKING REQUEST.\n');
  http.get(api, (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
      resolve(JSON.parse(data).results[0]);
    });
    res.on('error', (err) => { reject(err); });
  });
});

(async () => {
  try {
    console.log(`GETTING COORDINATES FOR: ${search.toUpperCase()}.\n`);
    const data = await getSearch();
    console.log('RECEIVED DATA:');
    console.log(`LAT: ${data.geometry.location.lat}`);
    console.log(`LON: ${data.geometry.location.lng}`);
  } catch (err) {
    console.error('\nERROR:\n', err);
  } finally {
    console.log('\nDONE.\n');
    process.exit();
  }
})();
