import { db } from 'db';
import type { OxAccountPermissions, OxAccountRoles } from 'types';

type DbAccountRow = OxAccountPermissions & { id?: number; name?: OxAccountRoles };

const accountRoles = {} as Record<OxAccountRoles, OxAccountPermissions>;

export function CheckRolePermission(roleName: OxAccountRoles | null, permission: keyof OxAccountPermissions) {
  if (!roleName) return;

  return accountRoles?.[roleName]?.[permission];
}

async function LoadRoles() {
  const roles = await db.execute<DbAccountRow>(`SELECT * FROM account_roles`);

  if (!roles[0]) return;

  roles.forEach((role) => {
    const roleName = role.name as OxAccountRoles;
    delete role.name;
    delete role.id;

    accountRoles[roleName] = role;
  });
}

setImmediate(LoadRoles);
