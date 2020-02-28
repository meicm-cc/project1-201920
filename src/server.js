const config = require('config')

const settings = config.get("settings")

const express = require('express')
const bodyParser = require('body-parser')
const CORS = require('cors')

const sgMail = require('@sendgrid/mail');


try {
    const app = express()
    app.use(bodyParser.urlencoded({ extended: true }))
    app.use(bodyParser.json({ limit: '10mb' }))
    app.use(CORS())


    // ROUTES
    app.use('/', express.static(__dirname))

    app.post('/message',(request,response,next)=>{
        const data = request.body
        const key = process.env.SENDGRID_API_KEY
        sgMail.setApiKey(key)
        const msg = {
            to: [settings.email, 'ricardo.p.gomes@ipleiria.pt'],
            from: data.email,
            subject: `Email from ${data.name}`,
            text: data.message
        }
        console.log(msg)
        sgMail.send(msg)
        .then(result=>{
            response.json({msg:'message sent',status:'OK'})
            return next()
        })
        .catch(error=>{
            console.error(error)
            for(let line of error.response.body.errors ){
                console.error(line);
            }
            response.json({msg:'error sendinng message',status:'NOT OK'})
            return next()
            
        })

        
    })

    app.listen(settings.port, () => {
        let env = process.env.NODE_ENV ? process.env.NODE_ENV : 'default'
        console.info('Running in %s environment', env)
        console.info('Server is up and running at: http://%s:%d ', settings.hostname, settings.port)
      })

} catch (error) {
    const stack = error.stack
    console.error("ERROR Creating Server " + error)
    console.error(stack)
}
