package org.eclipse.xtend.core

import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.core.xtend.XtendPackage
import org.eclipse.xtext.common.types.TypesPackage
import org.eclipse.xtext.xbase.XbasePackage
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage
import org.eclipse.xtext.xtype.XtypePackage
import com.google.inject.Injector

/** 
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
class XtendStandaloneSetup extends XtendStandaloneSetupGenerated {

	override Injector createInjectorAndDoEMFRegistration() {
		// don't call super, since that would create useless injectors for all the super languages.
		// register default ePackages
		if (!Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().containsKey("ecore")) Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().
			put("ecore", new org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl())
		if (!Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().containsKey("xmi")) Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().
			put("xmi", new org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl())
		if (!Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().containsKey("xtextbin")) Resource.Factory.Registry.INSTANCE.
			getExtensionToFactoryMap().put("xtextbin", new org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl())
		if (!EPackage.Registry.INSTANCE.containsKey(org.eclipse.xtext.XtextPackage.eNS_URI)) EPackage.Registry.INSTANCE.put(
			org.eclipse.xtext.XtextPackage.eNS_URI, org.eclipse.xtext.XtextPackage.eINSTANCE)
		// // register used EPackages
		EPackage.Registry.INSTANCE.put(XtendPackage.eINSTANCE.getNsURI(), XtendPackage.eINSTANCE)
		EPackage.Registry.INSTANCE.put(XbasePackage.eINSTANCE.getNsURI(), XbasePackage.eINSTANCE)
		EPackage.Registry.INSTANCE.put(XAnnotationsPackage.eINSTANCE.getNsURI(), XAnnotationsPackage.eINSTANCE)
		EPackage.Registry.INSTANCE.put(TypesPackage.eINSTANCE.getNsURI(), TypesPackage.eINSTANCE)
		EPackage.Registry.INSTANCE.put(XtypePackage.eINSTANCE.getNsURI(), XtypePackage.eINSTANCE)
		var Injector injector = createInjector()
		register(injector)
		return injector
	}

	def static void doSetup() {
		new XtendStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
