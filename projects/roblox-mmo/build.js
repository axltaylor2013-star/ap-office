const fs = require('fs');

const config = fs.readFileSync('C:/Users/alfre/.openclaw/workspace/projects/roblox-mmo/scripts/Config.lua','utf8');
const itemDb = fs.readFileSync('C:/Users/alfre/.openclaw/workspace/projects/roblox-mmo/scripts/ItemDatabase.lua','utf8');
const dataMgr = fs.readFileSync('C:/Users/alfre/.openclaw/workspace/projects/roblox-mmo/scripts/DataManager.lua','utf8');

let ref=0;
function r(){return 'RBX'+(ref++);}

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
	<Item class="ReplicatedStorage" referent="${r()}">
		<Properties>
			<string name="Name">ReplicatedStorage</string>
		</Properties>
		<Item class="Folder" referent="${r()}">
			<Properties>
				<string name="Name">Modules</string>
			</Properties>
			<Item class="ModuleScript" referent="${r()}">
				<Properties>
					<string name="Name">Config</string>
					<ProtectedString name="Source"><![CDATA[${config}]]></ProtectedString>
				</Properties>
			</Item>
			<Item class="ModuleScript" referent="${r()}">
				<Properties>
					<string name="Name">ItemDatabase</string>
					<ProtectedString name="Source"><![CDATA[${itemDb}]]></ProtectedString>
				</Properties>
			</Item>
		</Item>
		<Item class="Folder" referent="${r()}">
			<Properties>
				<string name="Name">Remotes</string>
			</Properties>
			<Item class="RemoteEvent" referent="${r()}">
				<Properties>
					<string name="Name">LevelUp</string>
				</Properties>
			</Item>
			<Item class="RemoteEvent" referent="${r()}">
				<Properties>
					<string name="Name">XPUpdate</string>
				</Properties>
			</Item>
			<Item class="RemoteEvent" referent="${r()}">
				<Properties>
					<string name="Name">InventoryUpdate</string>
				</Properties>
			</Item>
		</Item>
	</Item>
	<Item class="ServerScriptService" referent="${r()}">
		<Properties>
			<string name="Name">ServerScriptService</string>
		</Properties>
		<Item class="Script" referent="${r()}">
			<Properties>
				<string name="Name">DataManager</string>
				<ProtectedString name="Source"><![CDATA[${dataMgr}]]></ProtectedString>
			</Properties>
		</Item>
	</Item>
	<Item class="Workspace" referent="${r()}">
		<Properties>
			<string name="Name">Workspace</string>
		</Properties>
		<Item class="SpawnLocation" referent="${r()}">
			<Properties>
				<string name="Name">SpawnLocation</string>
				<bool name="Anchored">true</bool>
				<Vector3 name="size">
					<X>6</X>
					<Y>1</Y>
					<Z>6</Z>
				</Vector3>
				<CoordinateFrame name="CFrame">
					<X>0</X><Y>1</Y><Z>50</Z>
					<R00>1</R00><R01>0</R01><R02>0</R02>
					<R10>0</R10><R11>1</R11><R12>0</R12>
					<R20>0</R20><R21>0</R21><R22>1</R22>
				</CoordinateFrame>
			</Properties>
		</Item>
		<Item class="Part" referent="${r()}">
			<Properties>
				<string name="Name">Baseplate</string>
				<bool name="Anchored">true</bool>
				<Vector3 name="size">
					<X>512</X>
					<Y>1</Y>
					<Z>512</Z>
				</Vector3>
				<CoordinateFrame name="CFrame">
					<X>0</X><Y>0</Y><Z>0</Z>
					<R00>1</R00><R01>0</R01><R02>0</R02>
					<R10>0</R10><R11>1</R11><R12>0</R12>
					<R20>0</R20><R21>0</R21><R22>1</R22>
				</CoordinateFrame>
				<Color3uint8 name="Color3uint8">4293848814</Color3uint8>
			</Properties>
		</Item>
		<Item class="Part" referent="${r()}">
			<Properties>
				<string name="Name">WildernessBorder</string>
				<bool name="Anchored">true</bool>
				<float name="Transparency">0.699999988</float>
				<Vector3 name="size">
					<X>512</X>
					<Y>50</Y>
					<Z>2</Z>
				</Vector3>
				<CoordinateFrame name="CFrame">
					<X>0</X><Y>25</Y><Z>-100</Z>
					<R00>1</R00><R01>0</R01><R02>0</R02>
					<R10>0</R10><R11>1</R11><R12>0</R12>
					<R20>0</R20><R21>0</R21><R22>1</R22>
				</CoordinateFrame>
				<int name="BrickColor">21</int>
				<bool name="CanCollide">false</bool>
			</Properties>
		</Item>
		<Item class="Folder" referent="${r()}">
			<Properties>
				<string name="Name">SafeZone</string>
			</Properties>
		</Item>
		<Item class="Folder" referent="${r()}">
			<Properties>
				<string name="Name">Wilderness</string>
			</Properties>
		</Item>
		<Item class="Folder" referent="${r()}">
			<Properties>
				<string name="Name">ResourceNodes</string>
			</Properties>
		</Item>
	</Item>
	<Item class="StarterGui" referent="${r()}">
		<Properties>
			<string name="Name">StarterGui</string>
		</Properties>
	</Item>
	<Item class="StarterPlayer" referent="${r()}">
		<Properties>
			<string name="Name">StarterPlayer</string>
		</Properties>
		<Item class="StarterPlayerScripts" referent="${r()}">
			<Properties>
				<string name="Name">StarterPlayerScripts</string>
			</Properties>
		</Item>
	</Item>
</roblox>`;

fs.writeFileSync('C:/Users/alfre/.openclaw/workspace/projects/roblox-mmo/Wilderness.rbxlx', xml, 'utf8');
console.log('Done. Size:', fs.statSync('C:/Users/alfre/.openclaw/workspace/projects/roblox-mmo/Wilderness.rbxlx').size, 'bytes');
