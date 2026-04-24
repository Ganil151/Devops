/**
 * Web Performance Test (Node.js)
 * Description: Basic performance timing using fetch (Requires Node v18+)
 * Author: Senior DevOps Engineer
 * Version: 1.0 (Golden Standard)
 */

const url = process.argv[2];

if (!url) {
    console.error("Usage: node web-performance-test.js <url>");
    process.exit(1);
}

console.log(`Testing performance for: ${url}`);

async function testPerformance() {
    const start = performance.now();
    
    try {
        const response = await fetch(url);
        const ttfb = performance.now() - start;
        
        console.log(`\nStatus: ${response.status} ${response.statusText}`);
        console.log(`Time to First Byte (TTFB): ${ttfb.toFixed(2)} ms`);
        
        if (response.ok) {
            const blob = await response.blob();
            const end = performance.now();
            console.log(`Total Load Time: ${(end - start).toFixed(2)} ms`);
            console.log(`Size: ${(blob.size / 1024).toFixed(2)} KB`);
        }
        
    } catch (error) {
        console.error(`Error: ${error.message}`);
    }
}

testPerformance();
