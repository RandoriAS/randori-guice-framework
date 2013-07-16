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
package guice.reflection {
	public class TypeDefinition {
		
		public static const Constructor:int = 0;
		public static const Property:int = 1;
		public static const Method:int = 2;
		public static const View:int = 3;
		
		private var _type:*;
		private var _builtIn:Boolean = false;
		private var _className:String;

		public function get type():* {
			return _type;
		}
		
		public function get builtIn():Boolean {
			return _builtIn;
		}

		public function get isProxy():Boolean {
			return _type.isProxy;
		}

		public function get pending():Boolean {
			return _type.pending;
		}

		public function getClassName():String {

			if ( !_className ) {
				_className = _type.className;

				if ( !_className ) {
					//this could be native, in chrome we could check the name next
					_className = _type.name;

					if ( !_className ) {
						//Either we are not in Chrome or someone just passed us a random function
						//We can't tell at this point, so do a bit more work before giving up

						//function XMLHttpRequest(){ [Native Code] } for example
						var functionDef:String = _type.toString();
						var functionName:String = functionDef.substr( 9 );
						functionName = functionName.substring( 0, functionName.indexOf("{") );
						_className = functionName;

						if ( !_className ) {
							throw new Error("Cannot determine class name of requested injection " + functionDef );
						}
					}
				}

			}


			return _className;
		}
		
		public function getSuperClassName():String {
			var className:String = _type.superClassName;
			
			if (!className) {
				className = "Object";
			}
			
			return className;
		}

		public function getStaticDependencies():Vector.<String> {
			return this.type.getStaticDependencies();
		}

		public function getRuntimeDependencies():Vector.<String> {
			return this.type.getRuntimeDependencies();
		}

		private function injectionPoints(injectionType:int):Vector.<InjectionPoint> {
			return this.type.injectionPoints(injectionType) as Vector.<InjectionPoint>;
		}		
		
		public function getInjectionMethods():Vector.<MethodInjectionPoint> {
			return injectionPoints(Method) as Vector.<MethodInjectionPoint>;
		}
		
		public function getInjectionFields():Vector.<InjectionPoint> {
			return injectionPoints( Property );
		}
		
		public function getViewFields():Vector.<InjectionPoint> {
			return injectionPoints(View);
		}
		
		public function getConstructorParameters():Vector.<InjectionPoint> {
			return injectionPoints(Constructor);
		}
		
		public function constructorApply(args:Array):Object {
			var instance:Object = null;
			
			if ( this._builtIn ) {
				instance = new type();
			} else {
				//This is very JSy code to make a new object with unknown constructor args
				var f:*;
				var c:*;
				
				c = this.type; // reference to class constructor function
				f = new Function(); // dummy function
				f.prototype = c.prototype
				instance = new f(); // instantiate dummy function to copy prototype properties
				c.apply(instance, args); // call class constructor, supplying new object as context
				instance.constructor = c; // assign correct constructor (not f)
			}
			
			return instance;
		}

		public function TypeDefinition( clazz:Class ) {
			this._type = clazz;
			
			//We add data to all of our Types. So, if this is not one of our types, then we assume it is a built in or
			//externally defined. We dont want to spend much time trying to parse those
			if ( type.className == null ) {
				this._builtIn = true;
			}			
		}
	}
}