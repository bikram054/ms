Performance tests for the microservices using Apache JMeter

Files:
- `test-plan.jmx` - JMeter test plan with three Thread Groups: users, products, orders.
- `data/users.csv`, `data/products.csv`, `data/orders.csv` - sample CSV data used by the plan.

Quick run (GUI):
1. Open JMeter GUI (`jmeter`) and load `performance-tests/test-plan.jmx`.
2. Set property `testdir` if needed (default is plan location). Example: `-Jtestdir=performance-tests`.
3. Run the test and view results via Listeners (View Results in Table / Aggregate Report).

CLI run (non-GUI):

```bash
# run from project root
jmeter -n -t performance-tests/test-plan.jmx -l performance-tests/results.jtl -Jtestdir=performance-tests
```

Tuning:
- Edit thread counts and loop counts in `test-plan.jmx` per Thread Group.
- Use JMeter listeners or `jmeter` CLI with JTL output to analyze throughput/latency.

Notes:
- Services must be running locally (docker-compose up) on ports: user=8081, product=8082, order=8083.
- The CSV files provide sample IDs and bodies. Adjust to match real test data.

wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz
sudo tar -xvzf apache-jmeter-5.6.3.tgz -C /opt/
sudo ln -s /opt/apache-jmeter-5.6.3/bin/jmeter /usr/local/bin/jmeter
rm apache-jmeter-5.6.3.tgz