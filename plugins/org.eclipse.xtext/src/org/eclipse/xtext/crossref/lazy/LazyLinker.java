/*******************************************************************************
 * Copyright (c) 2008 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.eclipse.xtext.crossref.lazy;

import java.util.Iterator;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.InternalEObject;
import org.eclipse.emf.ecore.EPackage.Registry;
import org.eclipse.xtext.CrossReference;
import org.eclipse.xtext.GrammarUtil;
import org.eclipse.xtext.crossref.impl.AbstractLinker;
import org.eclipse.xtext.crossref.impl.LinkingDiagnosticProducer;
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer;
import org.eclipse.xtext.diagnostics.IDiagnosticProducer;
import org.eclipse.xtext.parsetree.AbstractNode;
import org.eclipse.xtext.parsetree.CompositeNode;
import org.eclipse.xtext.parsetree.NodeAdapter;
import org.eclipse.xtext.parsetree.NodeUtil;

import com.google.inject.Inject;

/**
 * @author Sven Efftinge - Initial contribution and API
 * 
 */
public class LazyLinker extends AbstractLinker {

	private final URIFragmentEncoder encoder;
	private Registry registry;

	@Inject
	public LazyLinker(URIFragmentEncoder encoder, EPackage.Registry registry) {
		this.encoder = encoder;
		this.registry = registry;
	}

	public void linkModel(EObject model, IDiagnosticConsumer consumer) {
		LinkingDiagnosticProducer producer = new LinkingDiagnosticProducer(consumer);
		clearAllReferences(model);
		installProxies(model, producer);
		TreeIterator<EObject> iterator = model.eAllContents();
		while (iterator.hasNext()) {
			EObject eObject = (EObject) iterator.next();
			installProxies(eObject, producer);
		}
	}
	
	private void clearAllReferences(EObject model) {
		clearReferences(model);
		final Iterator<EObject> iter = model.eAllContents();
		while (iter.hasNext())
			clearReferences(iter.next());
	}
	
	protected void clearReferences(EObject obj) {
		for(EReference ref: obj.eClass().getEAllReferences())
			clearReference(obj, ref);
	}

	protected void clearReference(EObject obj, EReference ref) {
		if (!ref.isContainment() && !ref.isContainer() && !ref.isDerived())
			obj.eUnset(ref);
	}

	protected void installProxies(EObject obj, IDiagnosticProducer producer) {
		NodeAdapter nodeAdapter = NodeUtil.getNodeAdapter(obj);
		if (nodeAdapter == null)
			return;
		final CompositeNode node = nodeAdapter.getParserNode();
		EList<AbstractNode> children = node.getChildren();
		for (AbstractNode abstractNode : children) {
			if (abstractNode.getGrammarElement() instanceof CrossReference) {
				CrossReference ref = (CrossReference) abstractNode.getGrammarElement();
				producer.setNode(abstractNode);
				final EReference eRef = GrammarUtil.getReference(ref, obj.eClass());
				if (eRef == null) {
					throw new IllegalStateException("Couldn't find EReference for crossreference " + ref);
				}
				createAndSetProxy(obj, abstractNode, eRef);
			}
		}
	}

	/**
	 * @param obj
	 * @param abstractNode
	 * @param eRef
	 */
	@SuppressWarnings("unchecked")
	protected void createAndSetProxy(EObject obj, AbstractNode abstractNode, EReference eRef) {
		URI uri = obj.eResource().getURI();
		URI encodedLink = uri.appendFragment(encoder.encode(obj, eRef, abstractNode));
		EClass eType = (EClass) eRef.getEType();
		eType = findInstantiableCompatible(eType);
		EObject proxy = eType.getEPackage().getEFactoryInstance().create(eType);
		((InternalEObject) proxy).eSetProxyURI(encodedLink);
		if (eRef.isMany()) {
			((EList<EObject>) obj.eGet(eRef)).add(proxy);
		} else {
			obj.eSet(eRef, proxy);
		}
	}

	/**
	 * @param eType
	 */
	private EClass findInstantiableCompatible(EClass eType) {
		if (!isInstantiatableSubType(eType,eType)) {
			// check local Package
			EPackage ePackage = eType.getEPackage();
			EClass eClass = findSubTypeInEPackage(ePackage, eType);
			if (eClass!=null)
				return eClass;
			// check registry
			for (String nsURI : registry.keySet()) {
				if (nsURI.equals(ePackage.getNsURI())) // avoid double check of local EPackage
					continue;
				EClass class1 = findSubTypeInEPackage(registry.getEPackage(nsURI),eType);
				if (class1!=null)
					return class1;
			}
		}
		return eType;
	}

	private EClass findSubTypeInEPackage(EPackage ePackage, EClass superType) {
		EList<EClassifier> classifiers = ePackage.getEClassifiers();
		for (EClassifier eClassifier : classifiers) {
			if (eClassifier instanceof EClass) {
				EClass c = (EClass) eClassifier;
				if (isInstantiatableSubType(c, superType))
					return c;
			}
		}
		return null;
	}

	private boolean isInstantiatableSubType(EClass c, EClass superType) {
		return !c.isAbstract() && !c.isInterface() && superType.isSuperTypeOf(c);
	}

}
