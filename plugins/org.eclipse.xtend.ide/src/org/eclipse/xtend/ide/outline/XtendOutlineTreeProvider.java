/*
* generated by Xtext
*/
package org.eclipse.xtend.ide.outline;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.model.IXtextDocument;
import org.eclipse.xtext.ui.editor.outline.IOutlineNode;
import org.eclipse.xtext.ui.editor.outline.IOutlineTreeProvider;
import org.eclipse.xtext.ui.editor.outline.impl.IOutlineTreeStructureProvider;
import org.eclipse.xtext.ui.editor.outline.impl.OutlineMode;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Composite TreeProvider which delegates to the active {@link AbstractMultiModeOutlineTreeProvider} implementation
 * 
 * @author Dennis Huebner
 */
public class XtendOutlineTreeProvider implements IOutlineTreeStructureProvider, IOutlineTreeProvider,
		IOutlineTreeProvider.ModeAware, IOutlineTreeProvider.Background {

	@Inject
	private Provider<XtendOutlineSourceTreeProvider> sourceProvider;

	@Inject
	private Provider<XtendOutlineJvmTreeProvider> jvmProvider;

	@Inject
	private IOutlineTreeProvider.ModeAware modeAware;

	private XtendOutlineSourceTreeProvider sourceTreeProvider;

	private XtendOutlineJvmTreeProvider jvmTreeProvider;

	@Inject
	private IPreferenceStoreAccess preferenceStoreAccess;

	private boolean showJvmModel;

	public IOutlineNode createRoot(IXtextDocument document) {
		readCurrentModeFromPrefStore();
		return treeProviderInUse().createRoot(document);
	}

	public void createChildren(IOutlineNode parentNode, EObject modelElement) {
		readCurrentModeFromPrefStore();
		treeProviderInUse().createChildren(parentNode, modelElement);
	}

	private void readCurrentModeFromPrefStore() {
		this.showJvmModel = preferenceStoreAccess.getPreferenceStore().getBoolean(
				SwitchOutlineModeContribution.PREFERENCE_KEY);
	}

	private AbstractMultiModeOutlineTreeProvider treeProviderInUse() {
		if (showJvmModel) {
			return getJvmTreeProvider();
		}
		return getSourceTreeProvider();
	}

	private final XtendOutlineJvmTreeProvider getJvmTreeProvider() {
		if (jvmTreeProvider == null) {
			jvmTreeProvider = jvmProvider.get();
			jvmTreeProvider.setModeAware(modeAware);
		}
		return jvmTreeProvider;
	}

	private final XtendOutlineSourceTreeProvider getSourceTreeProvider() {
		if (sourceTreeProvider == null) {
			sourceTreeProvider = sourceProvider.get();
			sourceTreeProvider.setModeAware(modeAware);
		}
		return sourceTreeProvider;
	}

	public List<OutlineMode> getOutlineModes() {
		return modeAware.getOutlineModes();
	}

	public OutlineMode getCurrentMode() {
		return modeAware.getCurrentMode();
	}

	public OutlineMode getNextMode() {
		return modeAware.getNextMode();
	}

	public void setCurrentMode(OutlineMode outlineMode) {
		modeAware.setCurrentMode(outlineMode);
	}

}
