(()=>{

    document.querySelector('form').addEventListener('submit',(event)=>{
        event.preventDefault()
        const data = {
            name : document.querySelector('#name').value,
            email : document.querySelector('#email').value,
            message : document.querySelector('#message').value,
        }
        
        axios.post('/message',data)
        .then(response=>{
            if(response.data.status && response.data.status == 'OK'){
                alert("Message Sent")
            } else {
                alert("Error Sending Message - Check Console")
            }
        })
        .catch(error=>{
            console.error(error)
            alert("Error Sending Message - Check Console")
        })
    })

})()