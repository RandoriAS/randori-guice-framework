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
package guice.resolver {
	import guice.loader.SynchronousClassLoader;
	import guice.reflection.TypeDefinition;
	
	import randori.webkit.page.Window;

	public class ClassResolver {
		private var loader:SynchronousClassLoader;
		
		public function resolveClassName(qualifiedClassName:String):TypeDefinition {
			var type:* = findDefinition(qualifiedClassName);
			
			if (type == null) {
				var classDefinition:String = loader.loadClass(qualifiedClassName);
				
				//Before we load it into memory, check on the super class and see if we need to load *that*
				//into memory. We may *NOT* have an inherit if we dont inherit from anything, that is just fine
				resolveParentClassFromDefinition(qualifiedClassName,classDefinition);
				
				//Load the newly found class memory
				addDefinition(classDefinition);
				
				//Get a reference to the newly added type
				type = findDefinition(qualifiedClassName);
				
				if (type == null) {
					//This alert shouldnt be here, we should figure out a way to get it to the UI level
					//HtmlContext.alert(qualifiedClassName + " does not contain required injection information ");
					throw new Error(qualifiedClassName + " does not contain required injection information ");
				}
				
				var td:TypeDefinition = new TypeDefinition(type);

				if (!td.builtIn) {
					//Finally, resolve any classes it references in its own code execution
					resolveClassDependencies(td);
				}
			}
			
			return new TypeDefinition(type);
		}
		
		private function resolveClassDependencies(type:TypeDefinition):void {
			var classDependencies:Vector.<String> = type.getClassDependencies();
			
			for ( var i:int=0; i<classDependencies.length; i++) {
				resolveClassName(classDependencies[i]);
			}
		}
		
		private function resolveParentClassFromDefinition( qualifiedClassName:String, classDefinition:String ):void {
			//\$Inherit\(net.digitalprimates.service.LabelService,([\w\W]*?)\)
			var inheritString:String = "\\$Inherit\\(";
			inheritString += qualifiedClassName;
			inheritString += ",\\s*(.*?)\\)";
			var inheritResult:Array = classDefinition.match(inheritString);
			
			//Do we inherit from anything?
			if (inheritResult != null) {
				//Resolve the parent class first
				resolveClassName(inheritResult[1]);
			}
		}
		
		private function findDefinition(qualifiedClassName:String):Object {
			var nextLevel:* = Window.window;
			var failed:Boolean = false;
			
			var path:Array = qualifiedClassName.split('.');
			
			for (var i:int = 0; i < path.length; i++) {
				nextLevel = nextLevel[path[i]];
				if (!nextLevel) {
					failed = true;
					break;
				}
			}
			
			if (failed) {
				return null;
			}
			
			return nextLevel;
		}
		
		[JavaScriptCode(file="_addDefinition.js")]
		private function addDefinition( definitionText:String ):void {
		}
		
		public function ClassResolver( loader:SynchronousClassLoader ) {
			this.loader = loader;
		}
	}
}