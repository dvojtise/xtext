/*
 * generated by Xtext
 */
package org.eclipse.xtext.purexbase.tests;

import com.google.inject.Inject;
import java.util.List;
import org.eclipse.emf.ecore.resource.Resource.Diagnostic;
import org.eclipse.xtext.purexbase.pureXbase.Model;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(PureXbaseInjectorProvider.class)
public class PureXbaseParsingTest {
	@Inject
	private ParseHelper<Model> parseHelper;
	
	@Test
	public void loadModel() throws Exception {
		Model result = parseHelper.parse("println('Hello world!')");
		Assert.assertNotNull(result);
		List<Diagnostic> errors = result.eResource().getErrors();
		Assert.assertTrue("Unexpected errors: " + IterableExtensions.join(errors, ", "), errors.isEmpty());
	}
}
