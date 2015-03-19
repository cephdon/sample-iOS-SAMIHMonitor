import groovy.json.JsonSlurper
import com.samsung.sami.manifest.Manifest
import com.samsung.sami.manifest.fields.*
import static com.samsung.sami.manifest.fields.StandardFields.*
import static com.samsung.sami.manifest.groovy.JsonUtil.*

public class CalorieTrackerManifest implements Manifest {
	static final CALORIES_INT = CALORIES.alias(Integer.class);
	static final COMMENTS = new FieldDescriptor("comments", String.class)

	@Override
	List<Field> normalize(String input) {
        def slurper = new JsonSlurper()
        def json = slurper.parseText(input)

        def fields = []

        addToList(fields, json, "calories", CALORIES_INT)
		addToList(fields, json, COMMENTS)

		return fields
	}

	@Override
	List<FieldDescriptor> getFieldDescriptors() {
		return [CALORIES_INT, COMMENTS]
	}
}