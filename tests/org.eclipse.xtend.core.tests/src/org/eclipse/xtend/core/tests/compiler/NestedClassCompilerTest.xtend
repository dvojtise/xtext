/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.core.tests.compiler

import org.junit.Test

/**
 * @author Sebastian Zarnekow - Initial contribution and API
 */
class NestedClassCompilerTest extends AbstractXtendCompilerTest {
	
	@Test
	def void testPlain() {'''
			class C {
				static class X {}
				X x
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public static class X {
			  }
			  
			  private C.X x;
			}
		''')
	}
	
	@Test
	def void testAbstractNestedClass() {'''
			class C {
				abstract static class X {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public static abstract class X {
			  }
			}
		''')
	}
	
	@Test
	def void testGetSuper_01() {'''
			class C {
				def void m2(A a) {
					a.super.m
				}
			}
			class A {
				def B getSuper() {
				}
			}
			class B {
				def void m() {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public void m2(final A a) {
			    B _super = a.getSuper();
			    _super.m();
			  }
			}
		''')
	}
	
	@Test
	def void testGetSuper_02() {'''
			class C {
				def void m2(A it) {
					super.toString
				}
			}
			class A {
				def Object getSuper() {
				}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public void m2(final A it) {
			    super.toString();
			  }
			}
		''')
	}
	
	@Test
	def void testOverloads() {'''
			class A {
				static class B {
					def void m(CharSequence c) {
						m('')
					}
				}
				def static void m(String s) {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class A {
			  public static class B {
			    public void m(final CharSequence c) {
			      this.m("");
			    }
			  }
			  
			  public static void m(final String s) {
			  }
			}
		''')
	}
	
	@Test
	def void testOverloadsOuterChosen() {'''
			class A {
				static class B {
					def void m(int i) {
						m('')
					}
				}
				def static void m(String s) {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class A {
			  public static class B {
			    public void m(final int i) {
			      A.m("");
			    }
			  }
			  
			  public static void m(final String s) {
			  }
			}
		''')
	}
	
	@Test
	def void testDeeplyNested() {'''
			class A {
				static interface B {
					class C {
						A a
						B b
						C c
						D d
						static class D {
							A a
							B b = new A.B {}
							C c = new C
							D d = new B.C.D {}
						}
					}
				}
				A a
				B b = new B {}
				B.C c
				B.C.D d
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class A {
			  public interface B {
			    public static class C {
			      public static class D {
			        private A a;
			        
			        private A.B b = new A.B() {
			        };
			        
			        private A.B.C c = new A.B.C();
			        
			        private A.B.C.D d = new A.B.C.D() {
			        };
			      }
			      
			      private A a;
			      
			      private A.B b;
			      
			      private A.B.C c;
			      
			      private A.B.C.D d;
			    }
			  }
			  
			  private A a;
			  
			  private A.B b = new A.B() {
			  };
			  
			  private A.B.C c;
			  
			  private A.B.C.D d;
			}
		''')
	}
	
	@Test
	def void testDeeplyNestedWithDollarSyntax() {'''
			class A {
				static interface B {
					class C {
						A a
						B b
						C c
						D d
						static class D {
							A a
							B b = new A$B {}
							C c = new C
							D d = new B$C$D {}
						}
					}
				}
				A a
				B b = new B {}
				B$C c = new B$C {}
				B$C$D d = new B$C$D
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class A {
			  public interface B {
			    public static class C {
			      public static class D {
			        private A a;
			        
			        private A.B b = new A.B() {
			        };
			        
			        private A.B.C c = new A.B.C();
			        
			        private A.B.C.D d = new A.B.C.D() {
			        };
			      }
			      
			      private A a;
			      
			      private A.B b;
			      
			      private A.B.C c;
			      
			      private A.B.C.D d;
			    }
			  }
			  
			  private A a;
			  
			  private A.B b = new A.B() {
			  };
			  
			  private A.B.C c = new A.B.C() {
			  };
			  
			  private A.B.C.D d = new A.B.C.D();
			}
		''')
	}
	
	@Test
	def void testOuterMemberAccess() {'''
			class C {
				static class X {
					new(C c) {
						c.m
					}
				}
				private def void m() {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public static class X {
			    public X(final C c) {
			      c.m();
			    }
			  }
			  
			  private void m() {
			  }
			}
		''')
	}
	
	@Test
	def void testSiblingAccess() {'''
			class C {
				static class X {
					new(Y y) {
						y.m
					}
				}
				private static class Y {
					private def void m() {}
				}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public static class X {
			    public X(final C.Y y) {
			      y.m();
			    }
			  }
			  
			  private static class Y {
			    private void m() {
			    }
			  }
			}
		''')
	}
	
	@Test
	def void testNestedInterface() {'''
			class C {
				interface I {}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  public interface I {
			  }
			}
		''')
	}
	
	@Test
	def void testNestedEnum() {'''
			class C {
				private static enum E {
					VAL
				}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  private enum E {
			    VAL;
			  }
			}
		''')
	}
	
	@Test
	def void testNestedAnnotation() {'''
			class C {
				package annotation A {
					String value = ''
				}
			}
		'''.assertCompilesTo('''
			@SuppressWarnings("all")
			public class C {
			  @interface A {
			    public String value() default "";
			  }
			}
		''')
	}
}
