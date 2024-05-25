package ${{ values.java_package_name }};

import io.sundr.transform.annotations.AnnotationSelector;
import io.sundr.transform.annotations.TemplateTransformation;
import io.sundr.transform.annotations.TemplateTransformations;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

@TemplateTransformations(annotations = @AnnotationSelector(RegisterRestClient.class), value = {
    @TemplateTransformation(value = "/chatbot.vm", gather = true),
    @TemplateTransformation(value = "/chatbot-ws.vm", gather = true),
    @TemplateTransformation("/tool.vm"),
})
public class Codegen {
}
