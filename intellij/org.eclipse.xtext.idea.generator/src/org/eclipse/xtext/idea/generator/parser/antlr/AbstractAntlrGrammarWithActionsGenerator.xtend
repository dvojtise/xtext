package org.eclipse.xtext.idea.generator.parser.antlr

import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.Group
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.UnorderedGroup
import org.eclipse.xtext.generator.parser.antlr.AntlrOptions

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.eclipse.xtext.GrammarUtil.*
import static extension org.eclipse.xtext.xtext.generator.parser.antlr.AntlrGrammarGenUtil.*

class AbstractAntlrGrammarWithActionsGenerator extends DefaultAntlrGrammarGenerator {
	
	override protected compileInit(AbstractRule it, AntlrOptions options) {
		switch it {
			ParserRule:
				compileEntryInit(options).toString
			default:
				super.compileInit(it, options)
		} 
	}
	
	protected def compileEntryInit(ParserRule it, AntlrOptions options) '''
		«IF definesHiddenTokens || definesUnorderedGroups(options)»
		@init {
			«compileInitHiddenTokens(options)»
			«compileInitUnorderedGroups(options)»
		}«ENDIF»'''

	protected def dispatch compileInitHiddenTokens(AbstractRule it, AntlrOptions options) {
		''
	}
	
	protected def dispatch compileInitHiddenTokens(ParserRule it, AntlrOptions options) 
		'''«IF definesHiddenTokens»HiddenTokens myHiddenTokenState = ((XtextTokenStream)input).setHiddenTokens(«FOR hidden:hiddenTokens SEPARATOR ', '»"«hidden.ruleName»"«ENDFOR»);«ENDIF»'''

	protected def dispatch compileInitUnorderedGroups(AbstractRule it, AntlrOptions options) {
		''
	}
		
	protected def dispatch compileInitUnorderedGroups(ParserRule it, AntlrOptions options) '''«IF definesUnorderedGroups(options)»
		UnorderedGroupState myUnorderedGroupState = getUnorderedGroupHelper().snapShot(
		«FOR group:eAllContentsAsList.filter(UnorderedGroup) SEPARATOR ', '»
			grammarAccess.«group.originalElement.gaRuleElementAccessor»
		«ENDFOR»
		);«ENDIF»'''
		
	override protected compileFinally(AbstractRule it, AntlrOptions options) {
		switch it {
			ParserRule:
				compileEntryFinally(options).toString
			default:
				super.compileFinally(it, options)
		}
	}
			
	protected def compileEntryFinally(ParserRule it, AntlrOptions options) '''
		«IF definesHiddenTokens || definesUnorderedGroups(options)»
		finally {
			«compileRestoreHiddenTokens(options)»
			«compileRestoreUnorderedGroups(options)»
		}«ENDIF»'''

	protected def dispatch compileRestoreHiddenTokens(AbstractRule it, AntlrOptions options) {
		''
	}
		
	protected def dispatch compileRestoreHiddenTokens(ParserRule it, AntlrOptions options)
			'''«IF definesHiddenTokens»myHiddenTokenState.restore();«ENDIF»'''

	protected def dispatch compileRestoreUnorderedGroups(AbstractRule it, AntlrOptions options) {
		''
	}
	
	protected def dispatch compileRestoreUnorderedGroups(ParserRule it, AntlrOptions options)
			'''«IF definesUnorderedGroups(options)»myUnorderedGroupState.restore();«ENDIF»'''
	
	override protected _dataTypeEbnf2(Group it, boolean supportActions) {
		if (it.guardCondition === null)
			super._dataTypeEbnf2(it, supportActions)
		else 
			guardConditionToAntlr + "(" + super._dataTypeEbnf2(it, supportActions) + ")"
	}
	
	override protected _dataTypeEbnf2(UnorderedGroup it, boolean supportActions) {
		if (supportActions) {
			val mandatoryContent = elements.filter[!optionalCardinality].size
			'''
				(
					{ 
					  getUnorderedGroupHelper().enter(grammarAccess.«originalElement.gaRuleElementAccessor»);
					}
					(
						(
				«FOR element:elements.indexed SEPARATOR '|'»
							(
								{getUnorderedGroupHelper().canSelect(grammarAccess.«originalElement.gaRuleElementAccessor», «element.key»)}?=>(
									{
										getUnorderedGroupHelper().select(grammarAccess.«originalElement.gaRuleElementAccessor», «element.key»);
									}
			«««	Predicate {true}=> helps to workaround an issue in the Antlr grammar processing
									({true}?=>(«element.value.dataTypeEbnf2(supportActions)»))«IF element.value.multipleCardinality»+«ENDIF»
									{ 
										getUnorderedGroupHelper().returnFromSelection(grammarAccess.«originalElement.gaRuleElementAccessor»);
									}
								)
							)
				«ENDFOR»
						)«IF mandatoryContent != 0»+
						{getUnorderedGroupHelper().canLeave(grammarAccess.«originalElement.gaRuleElementAccessor»)}?«ELSE»*«ENDIF»
					)
				)
					{ 
					  getUnorderedGroupHelper().leave(grammarAccess.«originalElement.gaRuleElementAccessor»);
					}
			'''
		} else {
			super._dataTypeEbnf2(it, supportActions)
		}
	}
	
	override protected _ebnf2(Group it, AntlrOptions options, boolean supportActions) {
		if (it.guardCondition === null)
			super._ebnf2(it, options, supportActions)
		else 
			guardConditionToAntlr + "(" + super._ebnf2(it, options, supportActions) + ")"
	}
	
	override protected _ebnf2(UnorderedGroup it, AntlrOptions options, boolean supportActions) {
		if (supportActions) {
			val mandatoryContent = elements.filter[!optionalCardinality].size
			'''
				(
					{ 
					  getUnorderedGroupHelper().enter(grammarAccess.«originalElement.gaRuleElementAccessor»);
					}
					(
						(
				«FOR element:elements.indexed SEPARATOR '|'»
							(
								{getUnorderedGroupHelper().canSelect(grammarAccess.«originalElement.gaRuleElementAccessor», «element.key»)}?=>(
									{
										getUnorderedGroupHelper().select(grammarAccess.«originalElement.gaRuleElementAccessor», «element.key»);
									}
			«««	Predicate {true}=> helps to workaround an issue in the Antlr grammar processing
									({true}?=>(«element.value.ebnf2(options, supportActions)»))«IF element.value.multipleCardinality»+«ENDIF»
									{ 
										getUnorderedGroupHelper().returnFromSelection(grammarAccess.«originalElement.gaRuleElementAccessor»);
									}
								)
							)
				«ENDFOR»
						)«IF mandatoryContent != 0»+
						{getUnorderedGroupHelper().canLeave(grammarAccess.«originalElement.gaRuleElementAccessor»)}?«ELSE»*«ENDIF»
					)
				)
					{ 
					  getUnorderedGroupHelper().leave(grammarAccess.«originalElement.gaRuleElementAccessor»);
					}
				'''
		} else {
			super._ebnf2(it, options, supportActions)	
		}
	}
	
	override protected _ebnf2(RuleCall it, AntlrOptions options, boolean supportActions) {
		super._ebnf2(it, options, supportActions) + getArgumentList(isPassCurrentIntoFragment, !supportActions)
	}
	
	override protected _dataTypeEbnf2(RuleCall it, boolean supportActions) {
		super._dataTypeEbnf2(it, supportActions) + getArgumentList(isPassCurrentIntoFragment, !supportActions)
	}
	
	override protected crossrefEbnf(AbstractRule it, RuleCall call, CrossReference ref, boolean supportActions) {
		super.crossrefEbnf(it, call, ref, supportActions) + call.getArgumentList(isPassCurrentIntoFragment, !supportActions)
	}
	
	override protected _assignmentEbnf(RuleCall it, Assignment assignment, AntlrOptions options, boolean supportActions) {
		super._assignmentEbnf(it, assignment, options, supportActions) + it.getArgumentList(isPassCurrentIntoFragment, !supportActions)
	}
	
	protected def isPassCurrentIntoFragment() {
		return false
	}
	
	protected def getCurrentType() {
		'EObject'
	}
	
}