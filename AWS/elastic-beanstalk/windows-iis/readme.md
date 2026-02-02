rm my-test-app.zip
rm ./temp-folder/static-site.zip

cd temp-folder
zip -r static-site.zip archive.xml parameters.xml Content/
cd ..
zip -r my-test-app.zip aws-windows-deployment-manifest.json static-site.zip .ebextensions/

Deploy to AWS