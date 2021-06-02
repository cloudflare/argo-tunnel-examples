addEventListener("fetch", event => {
    return event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
    // parse the URL and get someId
    const url = new URL(request.url)

    let postgrestParams = new URLSearchParams();
    let postgrestMethod
    let postgrestBody

    // if path starts with /new-random-visit, generate a random user and send data to database
    if(url.pathname.startsWith("/new")) {
        const res = await fetch("https://randomuser.me/api/")
        const randomUser = (await res.json()).results[0]
        postgrestMethod = "POST"
        postgrestBody = [{
            username: randomUser.login.username,
            country: randomUser.location.country.toLowerCase(),
            time: new Date().toISOString(),
        }]
    } else {
        postgrestMethod = "GET"
        // if country set, filter results
        const country = url.searchParams.get("country")
        if (country) {
            postgrestParams.append("country", `eq.${country.toLocaleLowerCase()}`)
        }
        postgrestParams.append("order", "time.desc")
    }
    
    // proxy the request to postgrest endpoint
    return fetch(`${POSTGREST_ENDPOINT}/visits?${postgrestParams.toString()}`, {
        method: postgrestMethod,
        body: JSON.stringify(postgrestBody),
        headers: {
            'Content-Type': 'application/json',
            'CF-Access-Client-Id': CF_ACCESS_CLIENT_ID,
            'CF-Access-Client-Secret': CF_ACCESS_CLIENT_SECRET,
        }
    })
}
