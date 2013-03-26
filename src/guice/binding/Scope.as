/***
 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package guice.binding {
	public class Scope {
		
		/** Instance Scope mean it is an instance scope with no Guice rules governing the recreation of the object. So, Type & Provider bindings will be executed as requested.
		 *  Instance bindings will always return the instance you configured, but you can reconfigure the instance binding in other contexts should you like.
		 *  
		 *  Singleton scope guarantees that guice will only provide a single instance of executed binding for the portions of the object graph under which the singleton is defined. In practice
		 *  if you define your singleton at the top level, it means all of the user created objects in the system.
		 *  
		 *  Context scope guarantees that Guice will only provide a single instance of the executed binding within the Context. However, unlike singletons, other contexts can redefine the 
		 *  binding. If a child context does not redefine a binding, guicejs will inquire with parent contexts.
		 **/		
		public static const Instance:int = 0;
		public static const Singleton:int = 1;
		public static const Context:int = 2;

	}
}