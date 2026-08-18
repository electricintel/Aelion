const byId = (id) => document.getElementById(id);
const endpoint = () => byId('endpoint').value.replace(/\/$/, '');
const headers = () => ({ 'Content-Type': 'application/json', Authorization: `Bearer ${byId('token').value || 'aelion-local-token'}` });

function setConnection(online) {
    byId('status-dot').className = online ? 'online' : 'offline';
    byId('connection-label').textContent = online ? 'API online' : 'API offline';
}

async function refresh() {
    try {
        const [health, metrics, events] = await Promise.all([
            fetch(`${endpoint()}/api/v1/health`, { headers: headers() }).then((response) => response.json()),
            fetch(`${endpoint()}/api/v1/metrics`, { headers: headers() }).then((response) => response.json()),
            fetch(`${endpoint()}/api/v1/events`, { headers: headers() }).then((response) => response.json())
        ]);
        setConnection(health.status === 'ok');
        ['requests', 'authorized', 'rejected', 'errors'].forEach((key) => { byId(key).textContent = metrics[key] ?? 0; });
        byId('events').textContent = metrics.last_event || 'No events received.';
        byId('last-seen').textContent = metrics.last_event ? 'Live' : 'Waiting';
        if (events.events && events.events[0]) byId('events').textContent = events.events[0].message;
    } catch (error) {
        setConnection(false);
        byId('response').textContent = error.message;
    }
}

byId('connect').addEventListener('click', refresh);
byId('send').addEventListener('click', async () => {
    try {
        const result = await fetch(`${endpoint()}/api/v1/requests`, { method: 'POST', headers: headers(), body: byId('request').value });
        byId('response').textContent = JSON.stringify(await result.json(), null, 2);
        refresh();
    } catch (error) { byId('response').textContent = error.message; }
});

refresh();
setInterval(refresh, 3000);
