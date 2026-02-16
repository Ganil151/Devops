/**
 * API Load Tester (Node.js)
 * Description: Simple async load generator for APIs
 */

const http = require('http');
const https = require('https');

const URL = process.argv[2];
const REQUESTS = parseInt(process.argv[3]) || 100;
const CONCURRENCY = parseInt(process.argv[4]) || 10;

if (!URL) {
    console.log("Usage: node api-load-tester.js <url> [requests] [concurrency]");
    process.exit(1);
}

const client = URL.startsWith('https') ? https : http;
let completed = 0;
let errors = 0;
let latencies = [];
let start = Date.now();

function makeRequest() {
    return new Promise((resolve) => {
        const reqStart = Date.now();
        const req = client.get(URL, (res) => {
            res.resume(); // Consume body
            res.on('end', () => {
                latencies.push(Date.now() - reqStart);
                resolve(res.statusCode);
            });
        });
        
        req.on('error', (e) => {
            errors++;
            resolve('error');
        });
    });
}

async function worker() {
    while (completed < REQUESTS) {
        completed++;
        await makeRequest();
        process.stdout.write(`\rProgress: ${completed}/${REQUESTS}`);
    }
}

async function run() {
    console.log(`Starting load test on ${URL}`);
    console.log(`Requests: ${REQUESTS}, Concurrency: ${CONCURRENCY}`);
    
    const workers = [];
    for (let i = 0; i < CONCURRENCY; i++) {
        workers.push(worker());
    }
    
    await Promise.all(workers);
    
    const end = Date.now();
    const duration = (end - start) / 1000;
    const avgLatency = latencies.reduce((a,b) => a+b, 0) / latencies.length;
    
    console.log("\n\nResults:");
    console.log(`Duration: ${duration.toFixed(2)}s`);
    console.log(`RPS: ${(REQUESTS / duration).toFixed(2)}`);
    console.log(`Avg Latency: ${avgLatency.toFixed(2)}ms`);
    console.log(`Errors: ${errors}`);
}

run();
