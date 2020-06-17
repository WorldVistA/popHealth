Some quick notes on popHealth v6 docker-compose:

1) I have used this project on both Windows Desktop and a couple different Ubuntu server hosts using the CE versions of docker.  I had a bit of trouble downloading the 'static measure' section on one server.  The work around was to simply pull the content manually and commented out the fetch section in pophealth.rake.  This hack (removing the cql_measure_json.zip fetch inside pophealth.rake) is NOT included here.  However, I do include a very similar hack to use a local instance of the bundle-2018.zip.  In this case, I figured it was easier to grab it once and re-use it rather than downloading every time.

2)  Some optional hacks are available as comments inside the pophealthweb Dockerfile, including both #1 above and using a pre-prepped popHealth.yml. Use what works best for you.

3) This version works -- but I have not gone back to optimize it.  Meaning, some of the image fetches are very specific -- for example the mongo:2.4.23 and the rabbitmq:3.7.14.  I have not gone back to complete test how flexible some of these things are -- or what kinds of code updates would be necessary to upgrade.  You'll also notice I create a new js-ecqm-engine-docker image.  I tried to use the public, available js-ecqm_engine docker image from docker hub.  But was not successful, so I ended up copying their docker file to build my own image.

4) In a similar vein as above (#3), I'm not sure if the #fix JSON Parse bit in the pophealthweb\Dockerfile is necessary.  This was an early experiment that was never revisited.  It doesn't seem to hurt... but I don't think it is needed.

5)  You'll notice the PH1 and PH2 folder instances.  These function as independent running stacks.  To create more iterations (PHn) simply copy PH1 and update the pophealthweb port (8082:80) to use a new, unique port (for example: 8084:80).  

6) The start up the running stack by:
     PS C:\docker\popHealthDocker - Public\PH1>docker-compose build
        -- and --
     PS C:\docker\popHealthDocker - Public\PH1>docker-compose up

   You can also start it up in detached mode.
   
7) pophealth v6 is already obsolete.  I expect this will have a limited shelf-life.  But it might find some use.
