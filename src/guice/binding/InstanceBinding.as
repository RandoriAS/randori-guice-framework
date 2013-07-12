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
import guice.IInjector;
import guice.reflection.TypeDefinition;

public class InstanceBinding implements IBinding {
	private var typeDefinition:TypeDefinition;
	private var instance:Object;

	public function getTypeName():String {
		return typeDefinition.getClassName();
	}

	public function getScope():int {
		return Scope.Instance;
	}

	public function destroy():void {
		typeDefinition = null;
	}

	public function provide(injector:IInjector):* {
		return instance;
	}

	public function InstanceBinding(typeDefinition:TypeDefinition, instance:Object) {
		this.typeDefinition = typeDefinition;
		this.instance = instance
	}
}
}