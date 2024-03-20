## To play with the new field

- Create a new template 
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: dummy
  title: Dummy template for testing purpose
  description: Dummy template for testing purpose
  tags:
    - dummy
spec:
  owner: guests
  type: service

  parameters:
    - title: Provide information for the Quarkus Application
      properties:
        QuarkusVersionList:
          title: Quarkus version
          type: array
          description: The list of the quarkus version
          ui:field: QuarkusVersionList

  steps:
  - id: register
    name: Registering the Catalog Info Component
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
      catalogInfoPath: /catalog-info.yaml
```
- Update your `all.yaml` file
```yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: quarkus-demo
  description: "A collection of the Backstage resources: org, user, templates for the Quarkus demo"
spec:
  targets:
    - ./org.yaml
    - ./entities.yaml
    - ./dummy/template.yaml
```
- Add it to your `app-config.local.yaml` file
```yaml
  locations:
    - type: file
      target: ../../temp/templates/all.yaml
      rules:
        - allow: [Template,Location,Component,System,Resource,User,Group]
```
- Launch the front and the backend in separate terminal
```bash
// terminal 1
yarn start

// terminal 1
yarn start-backend
```