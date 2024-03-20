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
      required:
        - component_id
        - owner
      properties:
        component_id:
          title: Name
          type: string
          description: Unique name of the application
          default: my-quarkus-app
          ui:field: EntityNamePicker

        QuarkusVersionList:
          title: Quarkus version
          type: array
          description: The list of the quarkus version
          ui:field: QuarkusVersionList
```
- Add it to your app-config.local.yaml file
```yaml
  locations:
    # Quarkus template, org, entity
    - type: file
      target: ../../temp/templates//org.yaml
    - type: file
      target: ../../temp/templates//entities.yaml
    - type: file
      target: ../../temp/templates/dummy/template.yaml
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